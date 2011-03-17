#
# Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
# Photo Model
# The photo object manages a single original photo and a number of resized photos that
# go along with it.  We use the PhotoAttachedImage class which is a child of AttachedImage
# to manage the photo an its generated photos.  Since we want to ensure no possible
# blocking in the handling of an app server request we defer any work that could take
# time which includes the upload/download/delete from s3 of the original and resized photos
# as well as the thumbnail generation itself.  Since the original uploaded file is handled
# by nginx and given to the server as a temp file we must do the initial deferred s3 upload
# on the same physical server that it arrived on.  After this step, the resizing processing
# is handled by a cpu bound work queue that in production is on a dedicated server(s) separate
# from the app servers.  All reliance on PaperClip has been removed as it created many issues
# and performance bottlenecks, and temp file leaks.
#
# Additional processing: we now support auto rotation as part of the resizing step.  This has
# been implemented in a way that should allow us to also issue a resize command in the future
# which will kick off a regeneration of the resized files with new rotation applied.  In addition,
# the resized files uploaded to amazon will contain the header:
#
# x-amz-meta-rotate: amount
#
# This lets the client know the amount of rotation that has been applied by the server.  The header
# will be missing if no rotation has been applied.
#
#
#
# PHOTO STATE DEFINITION AND TRANSITIONS
# -assigned: DB Default.  The photo has been created by an agent and has been assigned to it. Its waiting to be updated with an image
# -uploading: The original file has been received from the agent and an upload operation has been queued
# -loaded: The photo has been updated to s3 with an image and is waiting to be processed
# -ready: The photo has been processed and moved to permanent storage. It is ready to use
#
# -error: An error has occurred. This may be transient as the system attempts to retry in many cases depending
# on the nature of the error.
#
require 'zz'
require 'bulk_id_generator'

class PhotoValidationError < StandardError
end

class Photo < ActiveRecord::Base

  attr_accessible :user_id, :album_id, :upload_batch_id, :agent_id, :source_guid, :caption,
                  :image_file_size, :capture_date, :source_thumb_url, :source_screen_url,
                  :rotate_to, :source_path, :guid_part, :latitude, :created_at, :id,
                  :updated_at, :image_content_type, :headline, :error_message, :image_bucket,
                  :orientation, :height, :suspended, :longitude, :pos, :image_path, :image_updated_at,
                  :generate_queued_at, :width, :state

  # this is just a placeholder used by the connectors to track some extra state
  # now that we do batch operations
  attr_accessor :temp_url

  has_one :photo_info, :dependent => :destroy
  belongs_to :album, :touch => :photos_last_updated_at
  belongs_to :user
  belongs_to :upload_batch

  has_many :like_mees,      :foreign_key => :subject_id, :class_name => "Like"
  has_many :likers,         :through => :like_mees, :class_name => "User",  :source => :user

  # when retrieving a search from the DB it will always be ordered by created date descending a.k.a Latest first
  default_scope :order => 'pos ASC, created_at ASC'

  before_create :init_for_create


  # Set up an async call for Processing and Upload to S3
  after_commit  :queue_upload_to_s3

  # Set up an async call for managing the deleted photo from s3
  after_commit  :queue_delete_from_s3, :on => :destroy

  validates_presence_of             :album_id, :user_id, :upload_batch_id


  # since we allow batch operations, we don't get the normal callbacks for things
  # like before_create.  So, to keep things simple we have this helper method
  # that is used when you plan to do a batch insert.  This lets us run the proper
  # initialization
  def self.new_for_batch(current_batch, parms)
    photo = self.new(parms)
    photo.upload_batch = current_batch
    photo.init_for_create
    return photo
  end

  # wrap the import call so we can do some of the things that normally
  # happen via callbacks
  def self.batch_insert(photos)
    # batch insert
    results = self.import(photos)

    # we assume all share the same album, so extract
    # the album_id and touch that album without instantiating a
    # new album
    if photos.count > 0
      photo = photos[0]
      album_id = photo.album_id
      Album.touch_photos_last_updated(album_id)
    end

    # now kick off the uploads since bulk does not call after commit (I don't think)
    photos.each do |photo|
      photo.queue_upload_to_s3
    end

    results
  end

  # group anything you would normally put into a before_create
  # callback here since this also gets called by new_for_batch
  def init_for_create
    set_guid_for_path
    set_default_position
  end


  # never, never, never call get_next_id inside a transaction since failure of the transaction would rollback the
  # fetch of the id which could result in duplicates being used.  If you need a set number of ids, set the reserve_count
  # to the amount that you want and manage them yourself
  def self.get_next_id(reserved_count = 1)
    BulkIdManager.next_id_for(Photo.table_name, reserved_count)
  end


  # generate a guid and attach to this object
  def set_guid_for_path
    self.guid_part = UUIDTools::UUID.random_create.to_s
  end

  # get an instance of the attached image helper class
  def attached_image
    @attached_image ||= PhotoAttachedImage.new(self, "image")
  end

  # returns the set of supported image types
  def supported_image_types
    @@supported_image_types ||= Set.new [ 'image/jpeg', 'image/png', 'image/gif' ]
  end


  # given the local image, determine all the exif info for the file
  # this is only called when we set up a local file to be uploaded
  # to s3
  def set_image_metadata
    data = PhotoInfo.get_image_metadata(self.source_path)
    self.photo_info = PhotoInfo.factory(data)
    if exif = data['EXIF']
      val = exif['DateTimeOriginal']
      self.capture_date = (DateTime.parse(val) unless val.nil?) rescue nil
      val = exif['Orientation']
      self.orientation = decode_orientation(val) unless val.nil?
      val = exif['GPSLatitude']
      val_ref = exif['GPSLatitudeRef']
      self.latitude = PhotoInfo.decode_gps_coord(val, val_ref) unless val.nil? || val_ref.nil?
      val = exif['GPSLongitude']
      val_ref = exif['GPSLongitudeRef']
      self.longitude = PhotoInfo.decode_gps_coord(val, val_ref) unless val.nil? || val_ref.nil?
    end
    if iptc = data['IPTC']
      self.headline = (iptc['Headline'] || '') if self.headline.blank?
      self.caption = (iptc['Caption'] || '') if self.caption.blank?
    end
    if file = data['File']
      val = file['MIMEType']
      self.image_content_type = val
      # give preference to File width and height because it takes into account any saved rotation done to the file already
      val = file['ImageHeight']
      self.height = val unless val.nil?
      val = file['ImageWidth']
      self.width = val unless val.nil?
    end


    if self.height.nil?
      # now special case for extracting width and height since it can be an any one of the
      # tags
      data.each_value do |map|
        h = map['ImageHeight']
        w = map['ImageWidth']
        if h != nil
          self.height = h
          self.width = w
          break  # and we are done
        end
      end
    end
  end

  # calculation of height that takes into account any rotation
  def rotated_height
    case self.orientation
      when 6, 8 then self.width
      else self.height
    end
  end

  # calculation of width that takes into account any rotation
  def rotated_width
    case self.orientation
      when 6, 8 then self.height
      else self.width
    end
  end

  # from the exiftool string orientation return standard orientation numeric format
  def decode_orientation orientation
    orientation =~ /(\d+)/
    case $1.to_i
      when 90 then 6
      when 180 then 3
      when 270 then 8
      else 1
    end
  end

  # from numeric orientation, return rotation degrees
  def orientation_as_rotation orientation
    case orientation
      when 6 then 90
      when 3 then 180
      when 8 then 270
      else 0
    end
  end

  #
  # Used to queue loading and processing for async.
  #
  def queue_upload_to_s3
    # If state marked as uploading, pass it on
    if !self.destroyed? && self.uploading? && @do_upload
      @do_upload = false
      ZZ::ZZA.new.track_transaction("photo.upload.s3.start", self.id)
      ZZ::Async::S3Upload.enqueue( self.id )
      logger.debug("queued for upload")
    end
  end

  #
  # Delete the s3 related objects in a deferred fashion
  #
  def queue_delete_from_s3
    # if we have uploaded the original
    # put the delete into the queue so that the s3 files get removed
    # in the unlikely event that the delete gets processed before the
    # upload then the photo object itself will no longer exist which
    # will keep the upload from ever taking place
    # also, we can't rely on the photo object itself since it won't 
    # exist by the time it gets processed.
    if self.image_bucket
      # get all of the keys to remove
      keys = attached_image.all_keys
      ZZ::ZZA.new.track_transaction("photo.upload.s3.delete", self.id)
      ZZ::Async::S3Cleanup.enqueue(self.image_bucket, keys)
      logger.debug("Photo queued for s3 cleanup")
    end
  end

  #
  # resize the original into various sizes and then
  # upload the newly sized files to s3
  # this should only be done in the context of a resque worker
  # since it is a long running operation and we would not want
  # to block the app server dispatch on it
  def resize_and_upload
    z = ZZ::ZZA.new
    z.track_transaction("photo.upload.resize.start", self.id)
    attached_image.resize_and_upload_photos
    z.track_transaction("photo.upload.resize.done", self.id)
    z.track_transaction("photo.upload.done", self.id)
    # tell the photo object it is good to go
    mark_ready
    save!
    complete = upload_batch.finish
    # update the status of this batch if not complete to show
    # that we've had activity
    upload_batch.touch if complete == false
  end

  # upload our temp source file to s3 and remove the temp if successful
  # this is called from the resque worker to avoid the upload
  # having to be done in the main app server dispatch
  #
  def upload_source
    begin
      if (self.source_path != nil)
        file = File.open(self.source_path, "rb")
        attached_image.upload(file)
        # original file is now up on S3 - the existence of image_path lets us know that
        # it has been uploaded

        # mark that we are queueing a generate command
        # this can be used to ensure that only the latest
        # queued command actually does the work to avoid needless
        # replication if prior command have been queued
        queued_at = Time.now
        self.generate_queued_at = queued_at

        # update state to loaded
        mark_loaded
        ZZ::ZZA.new.track_transaction("photo.upload.s3.done", self.id)
        save!
        # clean up temp file since it has been uploaded with no errors
        remove_source
        Rails.logger.debug("Upload of original file to S3 finished - queueing resize stage.")
        ZZ::Async::GenerateThumbnails.enqueue(self.id, queued_at.to_i)
      else
        raise "Photo upload_source did not have a valid source_path to upload from."
      end
    end
  end

  # remove our source file - called when the resque worker will
  # no longer attempt retries
  def remove_source
    File.delete(self.source_path) rescue nil
    self.source_path = nil
    # don't really want to trigger a new save so we don't explicitly kick off a new save
    # If the photo is not saved it should be
    # irrelevant since not used for anything after this point
  end

  def assigned?
    self.state == 'assigned'
  end

  def loaded?
    self.state == 'loaded'
  end

  def mark_loaded
    self.state = 'loaded'
  end

  def uploading?
    self.state == 'uploading'
  end

  def mark_uploading
    self.state = 'uploading'
  end

  def ready?
    self.state == 'ready'
  end

  def mark_ready
    self.state = 'ready'
  end

  def error?
    self.state == 'error'
  end

  def mark_error
    self.state = 'error'
  end


  # build the agent source url
  def self.make_agent_source(type, id, album_id)
    "http://localhost:30777/albums/#{album_id}/photos/#{id}.#{type}"
  end


  # safe version of source thumb
  # if nil which it can be if
  # processing photo from source such as email
  # return a default url
  def safe_url url
    url.nil? ? "/images/working.png" : url
  end

  def stamp_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::STAMP)
    else
      return safe_url(self.source_thumb_url)
    end
  end

  def thumb_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::THUMB)
    else
      return safe_url(self.source_thumb_url)
    end
  end

  def screen_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::MEDIUM)
    else
      return safe_url(self.source_screen_url)
    end
  end

  def full_screen_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::LARGE)
    else
      return safe_url(self.source_screen_url)
    end
  end


  def original_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::ORIGINAL)
    else
      return safe_url(self.source_screen_url)
    end
  end

  def aspect_ratio
    if(self.width && self.height && self.width != 0 && self.height != 0)
      return rotated_width.to_f / rotated_height.to_f
    else
      return 0
    end
  end

  def self.generate_source_guid(url)
     Digest::MD5.hexdigest(url)
  end

  def metadata
    if photo_info
      JSON.parse(photo_info.metadata)
    end
  end

  def metadata=(value_hash)
    self.photo_info = PhotoInfo.new unless self.photo_info
    self.photo_info.metadata = value_hash.to_json
  end

  #
  # verify valid parms for the file about to be uploaded
  # if attributes are invalid throw a validation exception
  #
  def verify_file_type
    image_type = self.image_content_type
    if supported_image_types.include?(image_type) == false
      msg = "Not a supported image type, you passed: " +  image_type
      errors.add(:image_content_type, msg)
      # save the error state
      self.mark_error
      raise PhotoValidationError.new(msg)
    end
  end


  #
  # handle set up for file upload
  # this call expects a file_path to be passed
  # the file_path is required and represents a local
  # path to a file that we will take ownership of - once this call is made
  # the file belongs to us and should not be deleted by the caller
  #
  #
  def file_to_upload=(file_path)
    begin
      if file_path
        if @do_upload || self.assigned? == false
          # if we are already uploading then we have bad state since someone may have
          # tried to set a photo twice - in this case set an internal flag so that we
          # fail validation - this would only ever be proper if we allowed for modification
          # in place
          # also only allow upload if in assigned state currently

          ZZ::ZZA.new.track_transaction("photo.upload.error.duplicate", self.id)
          msg = "file_to_upload was called multiple times or a photo upload is already in progress or has taken place"

          # note we do not change the database state to error since we don't want to mess up the current one
          errors.add(:image_path, msg)
          raise PhotoValidationError.new(msg)
        else
          ZZ::ZZA.new.track_transaction("photo.upload.start", self.id)

          @do_upload = true
          self.mark_uploading
          self.source_path = file_path
          self.image_file_size = File.size(file_path)

          # gather and set the image metadata based on this file
          # also sets content_type
          set_image_metadata

          # verify that file state is ok before moving forward
          verify_file_type

          # see if we should add any initial rotation based on the
          # camera orientation info
          self.rotate_to = orientation_as_rotation(self.orientation)

        end
      end
    rescue Exception => ex
      # don't do the upload if validation failed
      @do_upload = false

      # call failed so get rid of temp file right now
      remove_source

      self.save

      # reraise the error
      raise ex
    end
  end

  # we override the save method so we have a chance to clean up if we have accepted a file for upload
  # since our contract with the caller is that as soon as they hand it off to us we own it
  def save
    if !super
      cleanup_file_to_upload
      return false
    else
      return true
    end
  end

  def save!
    super
  rescue => ex
    cleanup_file_to_upload
    raise ex
  end

  # we no longer need the file so go ahead an delete it
  def cleanup_file_to_upload force=false
    if force || self.uploading?
      remove_source
    end
  end

  
  def self.to_json_lite(photos)
    # since the to_json method of an active record cannot take advantage of the much faster
    # JSON.fast_generate, we pull the object apart into a hash and generate from there.
    # In benchmarks I found that the generate method is 10x faster, so for instance the
    # difference between 10000/sec and 1000/sec

    hashed_photos = []
    photos.each do |photo|
      hashed_photo = {
        :id => photo.id,
        :caption => photo.caption,
        :state => photo.state,
        :source_guid => photo.source_guid,
        :upload_batch_id => photo.upload_batch_id,
        :user_id => photo.user_id,
        :aspect_ratio => photo.aspect_ratio,
        :stamp_url => photo.stamp_url,
        :thumb_url => photo.thumb_url,
        :screen_url => photo.screen_url,
        :full_screen_url => photo.full_screen_url
      }
      hashed_photos << hashed_photo
    end

    json = JSON.fast_generate(hashed_photos)


      #json= photos.to_json(:only =>[:id, :caption, :state, :source_guid, :upload_batch_id, :user_id], :methods => [:aspect_ratio, :stamp_url, :thumb_url, :screen_url, :full_screen_url])


    return json

  end


  def set_default_position

    #start with position as capture date in seconds
    self.pos = capture_date.to_i
    custom_order_offset = upload_batch.custom_order_offset

    # The current batch will be custom ordered if the album was custom ordered when batch was created.
    # This prevents having some photos in the batch in the middle  and some at the end of the album
    # if user starts custom ordering during upload.
    if custom_order_offset > 0
      # Shift entire batch to the end of the album in captured_date order.
      # each batch uses the pos of the last photo in the album at the time the batch is created 
      self.pos += custom_order_offset
    end


    #in case photos in batch have same capture date, we add a decimal to make them different
    # our ids for the same batch - by using the id it is possible for photos with the same
    # date to be handled by two different servers.  In that case the order of the ids is not
    # guaranteed.
    self.pos +=  ((self.id % 10000) / 10000.to_f)
  end

  # Used when the user reorders photos
  def position_between( before_photo_id, after_photo_id )
    if before_photo_id.nil? && after_photo_id.nil? 
            raise Exception, "Before & After Ids cannot both be null"
    end
    photos = album.photos
    return if photos.length <= 1     #cannot / no need to change position in one photo album

    if before_photo_id.nil? # insert at beginning
       after = photos.find(after_photo_id)
       self.pos = after.pos - 100;
    elsif after_photo_id.nil? #insert at end
       before = photos.find( before_photo_id )
       self.pos = before.pos + 100
    else  #insert in the middle
      after = photos.find(after_photo_id)
      before = photos.find( before_photo_id )
      self.pos =  ( before.pos + after.pos )/2
    end
    if album.custom_order == false
        album.custom_order = true
        album.save
    end
    save
  end
  
end


# this class simplifies the association of a named image
# in the database by managing the separate fields needed and
# also interfaces to S3 for upload/download/delete
class PhotoAttachedImage < AttachedImage

  # return the s3 key prefix
  def prefix
    @@prefix ||= "/i/"
  end

  # the template for the photo_sizes, specify the image suffix
  # followed by the options to pass to ImageMagick
  # these must be defined in order from largest to smallest size
  def sizes
    @@sizes ||= [
        {LARGE    => "-resize '2560x1440>' -strip -quality 80"},  # large
        {MEDIUM   => "-resize '1024x768>' -strip -quality 80"},  # medium
        {THUMB    => "-resize '180x180>' -strip -quality 80"},   # thumb
        {STAMP    => "-resize '100x100>' -strip -quality 80"}    # stamp
    ]
  end

  # return any custom commands such as rotation
  # this string is applied before any of the size operations
  # and only on the whole set
  # you should not update the model related to this
  # until the custom_metadata call occurs
  #
  def custom_commands
    rotate_to = model.rotate_to
    if rotate_to != 0
      "-rotate #{rotate_to}"
    else
      nil
    end
  end

  # generate the custom metadata headers to be stored along
  # with the resized objects return the object as a map
  # this call is made after the custom_commands call so this
  # is where you want to change the model state
  def custom_metadata
    rotate_to = model.rotate_to
    if rotate_to != 0
      model.rotate_to = 0 # rotation is done and recorded
      {
          "x-amz-meta-rotate" => rotate_to.to_s,
          "x-amz-meta-photo-id" => model.id.to_s,
          "x-amz-meta-album-id" => model.album_id.to_s,
          "x-amz-meta-user-id" => model.user_id.to_s
      }
    else
      nil
    end
  end
end
