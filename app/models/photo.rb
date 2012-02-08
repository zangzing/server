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
require 'zz_env_helpers'

class PhotoValidationError < StandardError
end

class Photo < ActiveRecord::Base
  # all of these need to be accessible because of batch insert
  attr_accessible :user_id, :album_id, :upload_batch_id, :agent_id, :source_guid, :caption,
                  :image_file_size, :capture_date, :source_thumb_url, :source_screen_url,
                  :rotate_to, :crop_json, :source_path, :guid_part, :latitude, :created_at, :id,
                  :updated_at, :image_content_type, :headline, :error_message, :image_bucket,
                  :orientation, :height, :suspended, :longitude, :pos, :image_path, :image_updated_at,
                  :generate_queued_at, :width, :state, :source, :deleted_at, :for_print, :original_suffix, :size_version,
                  :crc32, :import_context, :work_priority

  # this is just a placeholder used by the connectors to track some extra state
  # now that we do batch operations
  attr_accessor :temp_url, :inserting_for_batch, :temp_file_placeholder, :s3_upload_options

  has_one :photo_info, :dependent => :destroy
  belongs_to :album, :touch => :photos_last_updated_at, :counter_cache => true
  belongs_to :user
  belongs_to :upload_batch

  has_many :like_mees,      :foreign_key => :subject_id, :class_name => "Like"
  has_many :likers,         :through => :like_mees, :class_name => "User",  :source => :user

  # when retrieving a search from the DB it will always be ordered by created date descending a.k.a Latest first
  default_scope :order => 'capture_date ASC, created_at ASC, id ASC'

  before_create :init_for_create


  # Set up an async call for Processing and Upload to S3
  after_commit  :do_upload_to_s3

  # Set up an async call for managing the deleted photo from s3
  after_commit  :add_to_pending_delete, :on => :destroy

  after_commit  :change_cache_version

  validates_presence_of             :album_id, :user_id, :upload_batch_id


  # wrap the destroy in a deferred dispatch, allows us to batch cache invalidates
  def destroy
    DeferredCompletionManager.dispatch do
      super
    end
  end

  # since we allow batch operations, we don't get the normal callbacks for things
  # like before_create.  So, to keep things simple we have this helper method
  # that is used when you plan to do a batch insert.  This lets us run the proper
  # initialization
  def self.new_for_batch(current_batch, parms)
    photo = self.new(parms)
    photo.inserting_for_batch = true  # temporary state so we know internally we are being inserted as part of a batch
    photo.upload_batch = current_batch
    photo.init_for_create
    return photo
  end

  # this method takes existing photos in the ready
  # state and makes a copy of them.  you pass an array of
  # hashes that represent each photo and its options as:
  # [ {:photo => photo, :options => {:user_id =>, etc}}, ... ]
  #
  # The hash options you can set are:
  #
  # :user_id
  # :album_id
  # :upload_batch
  # :crop - new crop to be applied to copy
  # :rotate_to - new rotation
  # :for_print - will only produce print related resized photos
  #
  # returns the new copies array - the copy still has to go through the
  # resque jobs for copy of the s3 data and resizing steps so
  # is initially in the uploading state
  def self.copy_photos(originals)
    photos = []

    # fetch all the ids we need up front
    original_count = originals.length
    current_id = Photo.get_next_id(original_count) if original_count

    # copy all the photos
    originals.each do |original|
      # verify that all the originals are in the ready state
      original_photo = original[:photo]
      attr = original[:options] ? original[:options] : {}
      raise ArgumentError.new("Cannot copy a source photo that is not in the ready state") unless original_photo.ready?

      # now prepare to copy
      custom = attr[:upload_batch]
      upload_batch = custom.nil? ? UploadBatch.get_current_and_touch(original_photo.user_id, original_photo.album_id) : custom
      original_attrs = original_photo.attributes.dup.recursively_symbolize_keys!

      original_attrs[:id] = current_id
      current_id += 1 # bump for next one

      custom = attr[:user_id]
      original_attrs[:user_id] = custom unless custom.nil?
      custom = attr[:album_id]
      original_attrs[:album_id] = custom unless custom.nil?

      custom = attr[:rotate_to]
      original_attrs[:rotate_to] = custom unless custom.nil?
      crop = attr[:crop]
      original_attrs[:crop_json] = crop.to_json unless crop.nil?
      custom = attr[:for_print]
      original_attrs[:for_print] = custom unless custom.nil?


      photo = Photo.new_for_batch(upload_batch, original_attrs)
      photo.photo_info = PhotoInfo.new(:photo_id => photo.id, :metadata => original_photo.photo_info.metadata) unless original_photo.photo_info.nil?

      photo.mark_uploading
      photo.set_guid_for_path
      photo.image_path = nil
      photo.image_bucket = nil
      photo.source_path = nil
      photo.source_guid = "copy:#{UUIDTools::UUID.random_create}"
      photo.error_message = nil
      options = {}
      options[:copy_s3_object] = true
      options[:src_bucket] = original_photo.image_bucket
      options[:src_key] = original_photo.attached_image.key(AttachedImage.original_suffix(original_photo.original_suffix))
      options[:src_crc32] = original_photo.crc32
      photo.s3_upload_options = options
      photos << photo
    end

    # ok, now we have all of the photos ready to go, so do the bulk insert
    Photo.batch_insert(photos)

    photos
  end


  # wrap the import call so we can do some of the things that normally
  # happen via callbacks
  def self.batch_insert(photos)
    num_photos = photos.count
    return if (num_photos == 0)

    photo_infos = []
    album_ids = {}
    # gather details about the insert
    photos.each do |photo|
      album_id = photo.album_id
      album_count = album_ids[album_id]
      album_count = 0 if album_count.nil?
      album_count += 1
      album_ids[album_id] = album_count
      photo_info = photo.photo_info
      if photo_info
        photo_infos << photo_info
        photo_info.photo = photo # keep it from loading when referenced
        photo_info.photo_id = photo.id
      end
    end

    # batch insert the base photos
    results = self.import(photos)

    # and now the photo infos
    PhotoInfo.import(photo_infos) unless photo_infos.empty?

    # Touch each album_id without instantiating a
    # new album
    album_ids.each_pair do |album_id, photo_count|
      # bump the photo counter
      Album.update_counters album_id, :photos_count => photo_count
      Album.change_cache_version(album_id)
    end

    # now kick off the uploads since bulk does not call after commit
    photos.each do |photo|
      photo.inserting_for_batch = false
      photo.do_upload_to_s3
    end

    results
  end

  # group anything you would normally put into a before_create
  # callback here since this also gets called by new_for_batch
  def init_for_create
    set_guid_for_path
    set_default_position
    if self.capture_date.nil?
      # always make sure we have a capture date but if we had to set it, use the suspended flag to mark that it was originally null
      self.capture_date = Time.now
      self.suspended = 1
    end
    # assign a large random number to original suffix up to max unsigned 32 bit integer
    # we do this to ensure no one can guess the original from one of the smaller size photos
    self.original_suffix = rand(4294967295)
  end

  # never, never, never call get_next_id inside a transaction since failure of the transaction would rollback the
  # fetch of the id which could result in duplicates being used.  If you need a set number of ids, set the reserve_count
  # to the amount that you want and manage them yourself
  def self.get_next_id(reserved_count = 1)
    BulkIdManager.next_id_for(Photo.table_name, reserved_count)
  end

  # never call this within a transaction because if a rollback happens
  # on the id generator you will end up with duplicate ids
  def change_cache_version
    album_id = self.album_id
    # see if the parent album is being deleted, in which case we don't want to do anything
    if Album.album_being_deleted?(album_id) == false
      Album.change_cache_version(album_id) unless album_id.nil?
    end
  end

  # generate a guid and attach to this object
  def set_guid_for_path
    self.guid_part = UUIDTools::UUID.random_create.to_s
  end

  # get an instance of the attached image helper class
  def attached_image
    # don't know why but in development with resque worker the very first time it tries to access the image_bucket
    # attribute from within the PhotoAttachedImage initializer via the send method it throws an exception claiming
    # image_bucket is not a method on this class, touching it first seems to make it happy.  Something strange
    # with ActiveRecord?
    #
    wake = self.image_bucket
    @attached_image ||= PhotoAttachedImage.new(self, "image")
  end

  # returns the set of supported image types
  def self.supported_image_types
    @@supported_image_types ||= Set.new [ 'image/jpeg', 'image/png', 'image/gif', 'image/tiff' ]
  end

  # determine the type of the file from its magic header
  def get_magic_file_type(file_path)
    @@magic_types ||= [
        {:type => 'image/jpeg', :magic => [255,216,255,224]},
        {:type => 'image/jpeg', :magic => [255,216,255,225]},
        {:type => 'image/jpeg', :magic => [255,216,255,232]},
        {:type => 'image/png', :magic => [137,80,78,71]},
        {:type => 'image/gif', :magic => [71,73,70,56]},
        {:type => 'image/tiff', :magic => [77,77,0,42]},
        {:type => 'image/tiff', :magic => [73,73,42,0]},
    ]

    begin
      io = File.open(file_path,"rb")
      header = []
      header << io.getbyte
      header << io.getbyte
      header << io.getbyte
      header << io.getbyte

      # check the header against the magic types
      @@magic_types.each do |item|
        mime_type = item[:type]
        magic = item[:magic]
        if magic == header
          return mime_type
        end
      end
    ensure
      io.close() rescue nil
    end

    return ""
  end

  # given the local image, determine all the exif info for the file
  # this is only called when we set up a local file to be uploaded
  # to s3
  def set_image_metadata
    data = PhotoInfo.get_image_metadata(self.source_path)
    self.photo_info = PhotoInfo.factory(data)
    if exif = data['EXIF']

      val =  exif['DateTimeOriginal']
      parsed_date = DateTime.parse(val) rescue nil
      if parsed_date
        # a valid date so update and indicate set via exif
        self.capture_date = parsed_date
        self.suspended = 0
      end
      # finally make sure we never end up with a case where capture date is null
      if self.capture_date.nil?
        self.capture_date = self.created_at
        self.suspended = 1  # mark that capture date was null
      end

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
      cur_headline = safe_default(self.headline, '')
      cur_caption = safe_default(self.caption, '')
      self.headline = (iptc['Headline'] || '') if cur_headline.blank?
      self.caption = (iptc['Caption'] || '') if cur_caption.blank?
    end
    # determine the files type
    magic_type = get_magic_file_type(self.source_path)

    if file = data['File']
      if magic_type.empty?
        val = file['MIMEType']
      else
        val = magic_type
        file['MIMEType'] = magic_type
      end
      self.image_content_type = val
      # give preference to File width and height because it takes into account any saved rotation done to the file already
      val = file['ImageHeight']
      self.height = val unless val.nil?
      val = file['ImageWidth']
      self.width = val unless val.nil?
    else
      self.image_content_type = magic_type if !magic_type.empty?
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
    case self.rotate_to
      when 90, 270 then self.width
      else self.height
    end
  end

  # calculation of width that takes into account any rotation
  def rotated_width
    case self.rotate_to
      when 90, 270 then self.height
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

  # queue the upload with no checks
  def queue_upload_to_s3(options = {})
    ZZ::ZZA.new.track_transaction("photo.upload.s3.start", self.id)
    ZZ::Async::S3Upload.enqueue( self.id, options )
    logger.debug("queued for upload")
  end

  #
  # Used to queue loading and processing for async.
  # This is a callback from ActiveRecord so see if
  # we have something to do first.
  #
  def do_upload_to_s3
    # If state marked as uploading, pass it on
    if !self.destroyed? && self.uploading? && @do_upload
      @do_upload = false
      options = self.s3_upload_options ? self.s3_upload_options : {}
      queue_upload_to_s3(options)
    end
  end

  # Add to pending delete table
  # used to hold the underlying image link for future delete from s3
  #
  # in the unlikely event that the delete gets processed before the
  # upload then the photo object itself will no longer exist which
  # will keep the upload from ever taking place
  # also, we can't rely on the photo object itself since it won't
  # exist by the time it gets processed.
  def add_to_pending_delete
    Album.update_photos_ready_count(self.album_id, -1) if ready?
    if self.image_bucket
      original_suffix = AttachedImage.original_suffix(self.original_suffix)
      encoded_sizes = S3PendingDeletePhoto.encode_sizes(attached_image.sizes, original_suffix)
      pd = S3PendingDeletePhoto.create(
          :photo_id => self.id,
          :user_id => self.user_id,
          :album_id => self.album_id,
          :caption => self.caption,
          :prefix => attached_image.prefix,
          :encoded_sizes => encoded_sizes,
          :image_bucket => self.image_bucket,
          :guid_part => self.guid_part,
          :deleted_at => Time.now
      )
      # get all of the keys to remove
      ZZ::ZZA.new.track_transaction("photo.upload.s3.pending_delete", self.id)
      logger.debug("Photo posted to pending delete")
    end
  end

  # prepare and queue up an async rotate
  # for now we just do rotation in the future
  # change to support more functionality
  # We accept the following:
  # :rotate_to => the absolute degrees of rotation from the original
  # :crop => {:top => 0.12, :left => 0.0, :bottom => 0.9, :right => 0.8}
  #   crop amounts are floats that represent the percentage of crop from the left
  #   edge in the case of :left, :right, and percentage of crop from the top
  #   edge in the case of :top, :bottom.  0 for left, and 1 for right represents the full
  #   width and likewise 0 for top and 1 for bottom represents the full width.
  #
  #   The cropping is always done against the original unrotated photo, so if you
  #   apply rotation you need to make sure the crop coordinates make sense for that rotation
  #   For instance if you rotated 90 deg, from the users point of view the original left
  #   edge has now become the top.  To crop the left edge from the users perspective you would
  #   apply the cropping to the bottom which is now visually the left edge from the users perspective.
  #
  def start_async_edit(options)
    @@allowed_edit_options ||= Set.new([:rotate_to, :crop])
    @@required_crop_options ||= Set.new([:top, :left, :bottom, :right])

    raise "Cannot rotate until photo is loaded or ready." unless loaded? || ready?
    ZZUtils.require_at_least_one(options, @@allowed_edit_options, true)

    rotate_to = options[:rotate_to]
    unless rotate_to.nil?
      rotate_to = rotate_to.to_i
      raise "Rotation out of range, must be 0-359, you specified: #{rotate_to}" unless (0..359) === rotate_to
      self.rotate_to = rotate_to
    end

    crop = options[:crop]
    unless crop.nil?
      ZZUtils.require_all(crop, @@required_crop_options, true) do |key, value|
        f = Float(value)
        raise ArgumentError.new("Crop value for #{key} out of range, should be between 0 and 1 inclusive") if f < 0.0 || f > 1.0
        f
      end
      raise ArgumentError.new("left crop must be < right crop") unless crop[:left] <= crop[:right]
      raise ArgumentError.new("top crop must be < bottom crop") unless crop[:top] <= crop[:bottom]

      crop_json = JSON.fast_generate(crop)
      self.crop_json = crop_json
    end

    Rails.logger.debug("Sending async edit request.")
    queued_at = Time.now
    self.generate_queued_at = queued_at

    #mark_loaded    # debatable whether we really want this, because it might be best to keep in current (most likely ready) state so others can see...
    save!(false)  # don't want any cleanup since we are operating on an already upload file
    response_id = AsyncResponse.new_response_id
    ZZ::Async::GenerateThumbnails.enqueue_for_edit(self.id, queued_at.to_i, response_id)
    return response_id
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
    z.track_transaction("photo.upload.done", self.id, {:photo_source => self.source}, 1, self.user_id)
    # tell the photo object it is good to go
    was_ready = ready?
    mark_ready
    save!
    # bump count of ready photos if this one just became ready
    Album.update_photos_ready_count(self.album_id, 1) unless was_ready
    # this is a sanity check to work around a small
    # race condition we currently have with client side batch closes
    batch = self.upload_batch
    if batch
      complete = batch.finish
      # update the status of this batch if not complete to show
      # that we've had activity
      batch.touch if complete == false
    end
  end

  # computes crc32 given a file
  def self.compute_crc32(path)
    crc = 0
    File.open(path, 'rb') do |f|
      while bytes = f.read(128 * 1024) do
      crc = Zlib.crc32(bytes,crc)
      end
    end
    crc
  end

  # upload our temp source file to s3 and remove the temp if successful
  # this is called from the resque worker to avoid the upload
  # having to be done in the main app server dispatch
  #
  def upload_source(options = {})
    begin
      copy_s3_object = ZZUtils.as_boolean(options[:copy_s3_object])
      if (copy_s3_object || self.source_path != nil)
        if copy_s3_object
          # copying an exist s3 object
          src_bucket = options[:src_bucket]
          src_key = options[:src_key]
          self.crc32 = options[:src_crc32]
          attached_image.copy(src_bucket, src_key)
        else
          # doing a local file system copy
          path = self.source_path
          self.crc32 = Photo.compute_crc32(path)
          file = nil
          begin
            file = File.open(path, "rb")
            attached_image.upload(file)
          ensure
            file.close rescue nil if file
          end
        end
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
        # use base class save since we don't want clean up if upload fails
        save!(false)  # no auto cleanup on error

        Rails.logger.debug("Upload of original file to S3 finished - queueing resize stage.")
        ZZ::Async::GenerateThumbnails.enqueue(self.id, queued_at.to_i)
        # clean up temp file since it has been uploaded with no errors
        remove_source
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
    @do_upload = true
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
    "http://localhost:#{ZangZingConfig.config[:agent_port]}/albums/#{album_id}/photos/#{id}.#{type}"
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

  def full_size_url
    if self.ready?
      attached_image.url(PhotoAttachedImage::FULL)
    else
      return safe_url(self.source_screen_url)
    end
  end

  def original_url
    if self.ready?
      attached_image.url(AttachedImage.original_suffix(self.original_suffix))
    else
      return safe_url(self.source_screen_url)
    end
  end

  # return filename with extension
  # derived from the caption
  # append_info if set will be appended to the no_caption case
  def file_name_with_extension(dup_filter = Set.new, append_info = nil)
    full_type = safe_file_type
    extension = extension_from_type(full_type)
    name = self.caption.blank? ? no_caption_filler(append_info) : self.caption
    name = name.gsub(/\.#{extension}$/i, '')[0..230] # strip extension and limit to allow room for making unique
    pre_filt_name = name
    if dup_filter.include?(name.downcase)
      name = "#{pre_filt_name}-#{append_info}"
      # ok, see if still a dup, this time use random number till good
      max_tries = 100   # keep from looping forever, just accept a duplicate after trying this many times
      while (dup_filter.include?(name.downcase) && max_tries > 0)
        name = "#{pre_filt_name}-#{append_info}-#{rand(99999)}"
        max_tries -= 1
      end
    end
    dup_filter.add(name.downcase)
    filename = ZZUtils.build_safe_filename(name, extension)
  end

  def no_caption_filler(append_info)
    base = Time.now.strftime( '%y-%m-%d-%H-%M-%S' )
    base += "-#{append_info}" if append_info
    base
  end

  def extension_from_type(full_type)
    type = full_type.split('/')[1]
    extension = case( type )
                  when 'jpeg' then 'jpg'
                  when 'tiff' then 'tif'
                  else type
                end
  end

  # look at the file type and determine the best choice
  # based on our current state - defaults to returning image/jpeg
  # if all else fails
  def safe_file_type
    type = self.image_content_type.nil? ? 'image/jpeg' : self.image_content_type
  end

  # return the substitution form of the url
  # expects caller to perform a string substitution
  # with the type of resized photo wanted
  def base_subst_url
    # use #{size} literally as the suffix
    # since the client will substitute
    self.ready? ? attached_image.url('#{size}') : nil
  end

  # convert suffix if needed based on size version
  def suffix_based_on_version(suffix)
    attached_image.suffix_based_on_version(suffix)
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

  def self.valid_image_type?(image_type)
    Photo.supported_image_types.include?(image_type)
  end

  #
  # verify valid parms for the file about to be uploaded
  # if attributes are invalid throw a validation exception
  #
  def verify_file_type
    image_type = self.image_content_type
    if Photo.valid_image_type?(image_type) == false
      msg = "Not a supported image type, you passed: #{image_type}"
      errors.add(:image_content_type, msg)
      # save the error state
      self.mark_error
      raise PhotoValidationError.new(msg)
    end
  end

  # states where we can upload, we start off
  # in assigned but may be in error if a failure
  # happened and we want to retry
  def can_upload?
    self.assigned? || self.error?
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
      save_on_error = true
      if file_path
        if @do_upload || can_upload? == false
          # if we are already uploading then we have bad state since someone may have
          # tried to set a photo twice - in this case set an internal flag so that we
          # fail validation - this would only ever be proper if we allowed for modification
          # in place
          # also only allow upload if in assigned state currently

          ZZ::ZZA.new.track_transaction("photo.upload.error.duplicate", self.id)
          msg = "file_to_upload was called multiple times or a photo upload is already in progress or has taken place"

          # note we do not change the database state to error since we don't want to mess up the current one
          errors.add(:image_path, msg)
          save_on_error = false   # don't save the photo state
          raise PhotoValidationError.new(msg)
        else
          ZZ::ZZA.new.track_transaction("photo.upload.start", self.id)

          self.mark_uploading
          self.source_path = file_path
          self.image_file_size = File.size(file_path)

          # gather and set the image metadata based on this file
          # also sets content_type
          set_image_metadata

          # verify that file state is ok before moving forward
          verify_file_type

          # if non ordered and did not previously have a capture date, set position now
          if upload_batch.nil? == false && upload_batch.custom_order_offset == 0
            set_default_position
          end

          # see if we should add any initial rotation based on the
          # camera orientation info  - if rotation is already set
          # then do not change it - allows upload process to specify
          # any rotation wanted, useful for cases such as fetching zz photos
          # from the connector and not losing any existing rotation info
          self.rotate_to ||= orientation_as_rotation(self.orientation)

        end
      end
    rescue Exception => ex
      # don't do the upload if validation failed
      @do_upload = false

      # call failed so get rid of temp file right now
      remove_source

      # only save our state if we are not part of an insert batch operation
      self.error_message = ex.message
      self.save unless save_on_error == false || self.inserting_for_batch

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

  def save!(clean_up = true)
    super
  rescue Exception => ex
    cleanup_file_to_upload if clean_up
    raise ex
  end

  # we no longer need the file so go ahead an delete it
  def cleanup_file_to_upload force=false
    if force || self.uploading?
      remove_source
    end
  end

  # This tracks the version of the data
  # provided in a single hashed photo for
  # our api usage.  If you make a change
  # to the hash_one_photo method below
  # make sure you bump this version so
  # we invalidate the browsers cache for
  # old items.
  def self.hash_schema_version
    'v8'
  end

  # this method packages up the fields
  # we care about for return via json
  def self.hash_one_photo(photo)
    photo_sizes = nil
    photo_base = photo.base_subst_url
    if photo_base
      # ok, photo is ready so include sizes map
      photo_sizes = {
          :stamp            => photo.suffix_based_on_version(AttachedImage::STAMP),
          :thumb            => photo.suffix_based_on_version(AttachedImage::THUMB),
          :screen           => photo.suffix_based_on_version(AttachedImage::MEDIUM),
          :full_screen      => photo.suffix_based_on_version(AttachedImage::LARGE),
          :iphone_grid      => photo.suffix_based_on_version(AttachedImage::IPHONE_GRID),
          :iphone_grid_ret  => photo.suffix_based_on_version(AttachedImage::IPHONE_GRID_RET)
      }
    end
    hashed_photo = {
      :id => photo.id,
      :agent_id => photo.agent_id,
      :caption => photo.caption,
      :state => photo.state,
      :rotate_to => photo.rotate_to.nil? ? 0 : photo.rotate_to,
      :source_guid => photo.source_guid,
      :upload_batch_id => photo.upload_batch_id,
      :user_id => photo.user_id,
      :aspect_ratio => photo.aspect_ratio,
      :stamp_url => photo.stamp_url,  # todo, the 4 urls should be nil if photo_base is non nil
      :thumb_url => photo.thumb_url,
      :screen_url => photo.screen_url,
      :full_screen_url => photo.full_screen_url,
      :photo_base => photo_base,
      :photo_sizes => photo_sizes,
      :width => photo.width,
      :height => photo.height,
      :rotated_width => photo.rotated_width,
      :rotated_height => photo.rotated_height,
      :capture_date => photo.capture_date,
      :created_at => photo.created_at
    }
  end

  # Create a hash of all photos suitable for api use
  def self.hash_all_photos(photos)

    if photos.is_a?(Array) == false
      hashed_photos = hash_one_photo(photos)
    else
      hashed_photos = []
      photos.each do |photo|
        hashed_photo = hash_one_photo(photo)
        hashed_photos << hashed_photo
      end
    end
    return hashed_photos
  end

  def self.to_json_lite(photos)
    # since the to_json method of an active record cannot take advantage of the much faster
    # JSON.fast_generate, we pull the object apart into a hash and generate from there.
    # In benchmarks I found that the generate method is 10x faster, so for instance the
    # difference between 10000/sec and 1000/sec

    json = JSON.fast_generate(hash_all_photos(photos))

    return json
  end


  def set_default_position

    #start with position as capture date in seconds, if we have none use created_at, and finally now
    self.pos = Integer(self.capture_date || self.created_at || Time.now) rescue 0
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
    @@prefix ||= "i/"
  end

  # when for_print is set we return the print
  # sizes that we want for print generation
  def self.image_sizes(for_print = false)
    if for_print
      @@print_sizes ||= [
          {FULL    => {:cmd => "-strip -quality 90"}},  # no resize wanted since this will be used for print
      ]
    else
      @@normal_sizes ||= [
          {LARGE            => {:cmd => "-resize '2560x1440>' -strip -quality 80"}},  # large
          {MEDIUM           => {:cmd => "-resize '1024x768>' -strip -quality 80"}},  # medium

          # we use clone since we are center cropping and want to revert to current image chain after our operation
          # when we set clone to true we save the current image so the resize does not affect it as it does when
          # not cloning so place this under the next greater size than we need
          {IPHONE_COVER_RET => {:cmd => "-resize 620x188^ -gravity center -extent 620x188 -strip -quality 80", :clone => true}},
          {IPHONE_COVER     => {:cmd => "-resize 310x94^ -gravity center -extent 310x94 -strip -quality 80", :clone => true}},
          {IPHONE_GRID_RET  => {:cmd => "-resize 188x188^ -gravity center -extent 188x188 -strip -quality 80", :clone => true}},
          {IPHONE_GRID      => {:cmd => "-resize 94x94^ -gravity center -extent 94x94 -strip -quality 80", :clone => true}},

          {THUMB            => {:cmd => "-resize '180x180>' -strip -quality 93"}},   # thumb
          # due to the way the imagemagick convert call works where it always wants to do an implicit
          # -write on the last item we cannot use clone so make sure any items that need clone are always
          # above the last one
          {STAMP            => {:cmd => "-resize '100x100>' -strip -quality 80"}},    # stamp
      ]
    end
  end

  # the template for the photo_sizes, specify the image suffix
  # followed by the options to pass to ImageMagick
  # these must be defined in order from largest to smallest size
  def sizes
    PhotoAttachedImage.image_sizes(model.for_print)
  end


  # return any custom commands such as rotation
  # this string is applied before any of the size operations
  # and only on the whole set
  # you should not update the model related to this
  # until the custom_metadata call occurs
  #
  def custom_commands
    rotate_to = model.rotate_to.nil? ? 0 : model.rotate_to

    crop = ImageCrop.from_json(model.crop_json)
    crop_cmd = crop.crop_str(model.width, model.height) unless crop.nil?

    custom_command = crop_cmd || ''
    custom_command << " -rotate #{rotate_to}" if rotate_to != 0
    custom_command.empty? ? nil : custom_command
  end

  # tack on any custom data you want to go with the original
  def custom_metadata_original
    custom_meta = {
        "x-amz-meta-photo-id" => model.id.to_s,
        "x-amz-meta-album-id" => model.album_id.to_s,
        "x-amz-meta-user-id" => model.user_id.to_s
    }
  end

  # generate the custom metadata headers to be stored along
  # with the resized objects return the object as a map
  # this call is made after the custom_commands call so this
  # is where you want to change the model state
  def custom_metadata
    custom_meta = custom_metadata_original
    rotate_to = model.rotate_to.nil? ? 0 : model.rotate_to
    if rotate_to != 0
      custom_meta["x-amz-meta-rotate"] = rotate_to.to_s
    end
    crop = ImageCrop.from_json(model.crop_json)
    unless crop.nil?
      custom_meta["x-amz-meta-crop-top"] = crop.top.to_s
      custom_meta["x-amz-meta-crop-left"] = crop.left.to_s
      custom_meta["x-amz-meta-crop-bottom"] = crop.bottom.to_s
      custom_meta["x-amz-meta-crop-right"] = crop.right.to_s
    end
    custom_meta
  end
end
