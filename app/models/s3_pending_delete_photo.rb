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

  # given a sizes map, convert to a string with a char for each size
  def self.encode_sizes(sizes, include_original)
    encoded_sizes = ""
    encoded_sizes << AttachedImage::ORIGINAL if include_original
    # now see if any resized photos to go with
    sizes.each do |map|
      map.each do |suffix, option|
        encoded_sizes << suffix
      end
    end
    encoded_sizes
  end

  # given a sizes string (such as omt), convert
  # to a set of s3 keys for removal
  def self.make_keys(guid_part, prefix, encoded_sizes)
    keys = []
    encoded_sizes.chars.each do |suffix|
      key = AttachedImage.build_s3_key(prefix, guid_part, suffix)
      keys << key
    end
    keys
  end

  def build_s3_url(suffix)
    AttachedImage.build_s3_url(self.image_bucket, self.prefix, self.guid_part, suffix, self.deleted_at)
  end
end