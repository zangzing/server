# This model holds the pending photos deletes for S3
# When a photo is deleted, we hold onto the underlying
# image data for a period of time before doing the
# delete from s3 of the original photo and all generated photos.
#
# This allows us a chance of recovering photos for a user that
# have been accidentally deleted and also ensures that when
# we create commerce related orders that we do not delete
# the original photo until the order has been processed.
#
# Note: that we only keep a fairly minimal set of data
# and don't currently have an easy way to turn these back
# into usable photos.  In the future we should probably
# add a method that restores the photos into a "Recovered Photos"
# album for a given user that they can then use to recover them.
#
class S3PendingDeletePhoto < ActiveRecord::Base
  MAX_DELETES_PER_SWEEP = 300  # maximum number we will delete in each sweep
  DELETE_AFTER = 15.days

  attr_accessible :photo_id, :user_id, :album_id, :caption, :prefix, :encoded_sizes,
                  :guid_part, :image_bucket,:deleted_at

  after_commit  :queue_delete_from_s3, :on => :destroy

  #
  # Delete the s3 related objects in a deferred fashion
  #
  def queue_delete_from_s3
    # if we have uploaded the original
    # put the delete into the queue so that the s3 files get removed
    # get all of the keys to remove
    keys = S3PendingDeletePhoto.make_keys(self.guid_part, self.prefix, self.encoded_sizes)
    ZZ::ZZA.new.track_transaction("photo.upload.s3.delete", self.photo_id)
    ZZ::Async::S3Cleanup.enqueue(self.image_bucket, keys)
    logger.debug("Photo queued for s3 cleanup")
  end

  # given a sizes map, convert to a string with : as a separator
  def self.encode_sizes(sizes, original_suffix)
    encoded_sizes = ""
    encoded_sizes << original_suffix if original_suffix
    # now see if any resized photos to go with
    sizes.each do |map|
      map.each do |suffix, option|
        encoded_sizes << ':' if encoded_sizes.length > 0
        encoded_sizes << suffix
      end
    end
    encoded_sizes
  end

  # given a sizes string (such as o:m:t), convert
  # to a set of s3 keys for removal
  def self.make_keys(guid_part, prefix, encoded_sizes)
    keys = []
    encoded_sizes = encoded_sizes.split(':')
    encoded_sizes.each do |suffix|
      key = AttachedImage.build_s3_key(prefix, guid_part, suffix)
      keys << key
    end
    keys
  end

  def build_s3_url(suffix)
    AttachedImage.build_s3_url(self.image_bucket, self.prefix, self.guid_part, suffix, self.deleted_at)
  end

  # Does the actual queueing up of the deletes and
  # removes the items efficiently.
  # this version lets you pass the ago and limit
  # returns the number of items deleted
  def self.queue_deletes(ago, limit)
    item_ids = []

    # we lock this and run in a transaction to keep another
    # sweeper from fighting us for the same photos. We keep
    # the max size relatively small so we should not be
    # within this transaction for more than a few seconds
    # the actual s3 deletes are done by a worker job, we
    # simply queue them up here
    S3PendingDeletePhoto.transaction do
      items = S3PendingDeletePhoto.lock.where("deleted_at <= :ago", :ago => ago).limit(limit)
      items.each do |item|
        #puts "Deleting from s3: #{item.id}"
        item.queue_delete_from_s3
        item_ids << item.id
      end
      # now do a single fast delete
      # we are inside a transactions so if we were to fail the
      # delete would occur later - even if we end up calling the underlying
      # s3 delete mechanism more than once we would be fine since it
      # simply ignores any error from s3 on delete
      unless item_ids.empty?
        S3PendingDeletePhoto.delete_all(:id => item_ids)
      end

      item_ids.length
    end
  end

  # this is called by the sweeper once a minute
  # we use this to queue up deletes - we limit the max
  # we will do per sweep
  def self.sweep_deletes
    queue_deletes(DELETE_AFTER.ago, MAX_DELETES_PER_SWEEP)
  end

end
