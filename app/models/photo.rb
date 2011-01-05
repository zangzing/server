#
# Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
# Photo Model
# As a first implementation images are attached to photo objects using paperclip as
# performance and customization changes are required the use of paperclip can be
# revisited or we can contribute the improvements to paperclip.
#
# The way paperclip works is:
# A photo is received in a create or update request as part of a multi-part form post.
# The model assigns the photo to a paperclip attachment triggering paper clip to move the file to storage
# Then using the stored file, paperclip uses imagemagick to create the required styles.
# During the whole time, the requester is kept waiting. (This model has been updated to have async
# processing and storage of images)
#
# TODO: We should investigate the possibility of using graphicmagick instead if its faster.
#
#
# ASYNC UPLOADING AND PROCESSING
#
# To improve speed of upload, the S3 backend loading and image processing is asynchronous.
# - The photo uploaded into a tmp file by the web server.
# - The tmp photo is stored into the local_image attachment attribute which is set for local storage no styles.
# - Using an after_save callback an async call to upload_to_s3 is queued using resque.
# - When the queued call is processed, the image attribute is set to local_image triggering paperclip
#   to store and process image. The image attachment is set to store in S3 with styles.
# - local_image is set to nil never to be used again =)
#
# PHOTO STATE DEFINITION AND TRANSITIONS
# -new:  No longer used. The DB default for a new photo is assigned
# -assigned: DB Default.  The photo has been created by an agent and has been assigned to it. Its waiting to be updated with an image
# -loaded: The photo has been updated with an image and is waiting to be processed
# -processing: The photo has been taken for the processing queue and its being processed
# -ready: The photo has been processed and moved to permanent storage. It is ready to use
# -deleted: The photo has been deleted and its waiting to be removed from storage.
#
# Once a photo goes assigned it needs to be updated with an image. When successful it goes loaded
# An assigned photo that is updated will trigger an async load to s3
#
# NOTES:
# The paperclip default url is used to display a temporary graphic while the local_image is processed.
# Code to accelerate a local development server was added and it may be removed for production TODO:
#
require 'zz'

class Photo < ActiveRecord::Base
  usesguid
  has_one :photo_info, :dependent => :destroy
  belongs_to :album
  belongs_to :user
  belongs_to :upload_batch

  # when retrieving a search from the DB it will always be ordered by created date descending a.k.a Latest first
  default_scope :order => 'capture_date DESC, created_at DESC'


  before_create :substitute_source_urls


  # Set up an async call for Processing and Upload to S3
  after_validation  :queue_upload_to_s3, :on => :update


  # used to receive image and queue for processing. User never sees this image. Paperclip defaults are local no styles
  has_attached_file :local_image, Paperclip.options[:local_image_options]

  has_attached_file :image, Paperclip.options[:image_options]


  validates_presence_of             :album_id, :user_id, :upload_batch_id


  validates_attachment_presence     :local_image,{
                                    :message => "file must be specified",
                                    :if =>  "persisted? && assigned?"
                                    #:if =>  :requires_local_image?
                                    }
  validates_attachment_size         :local_image,{
                                    :less_than => 10.megabytes,
                                    :message => "must be under 10 Megs",
                                    :if =>  "persisted? && assigned?"
                                    #:if =>  :requires_local_image?
                                    }
  validates_attachment_content_type :local_image,{
                                    :content_type => [ 'image/jpeg', 'image/png', 'image/gif' ],
                                    :message => " must be a JPEG, PNG, or GIF",
                                    :if =>  "persisted? && assigned?"
                                    #:if =>  :requires_local_image?
                                    }

  before_local_image_post_process :set_local_image_metadata
  before_image_post_process       :set_image_metadata

  def set_local_image_metadata
    self.local_image_path = local_image.path
    false
  end

  def set_image_metadata
    self.image_path   = image.path.match(/(^.*)\/original\/(.*$)/i)[1]
    self.image_bucket = image.instance_variable_get("@bucket")
    self.photo_info = PhotoInfo.factory(self)
    if data = self.metadata
      if exif = data["EXIF"]
        val = exif['DateTimeOriginal']
        self.capture_date = DateTime.parse(val) unless val.nil?
        val = exif['ExifImageHeight']
        self.length = val.to_i unless val.nil?
        val = exif['ExifImageWidth']
        self.width = val.to_i unless val.nil?
        # 1 means horizontal, 0 vertical
        val = exif['Orientation']
        self.orientation = val == "Horizontal (normal)" ? 1 : 0 unless val.nil?
        val = exif['GPSLatitude']
        val_ref = exif['GPSLatitudeRef']
        self.latitude = PhotoInfo.decode_gps_coord(val, val_ref) unless val.nil? || val_ref.nil?
        val = exif['GPSLongitude']
        val_ref = exif['GPSLongitudeRef']
        self.longitude = PhotoInfo.decode_gps_coord(val, val_ref) unless val.nil? || val_ref.nil?
      end
      if iptc = data["IPTC"]
        self.headline = (iptc['Headline'] || '') if self.headline.blank?
        self.caption = (iptc['Caption'] || '') if self.caption.blank?
      end
    end
    if uploading?
        false # halts thumbnail it will be queued in upload_to S3 - not currently used due to one step process
    end
  end

  #
  # Used to queue loading and processing for async.
  #
  def queue_upload_to_s3
    # If an assigned image has been loaded with an image, reprocess and send to S3
    if self.assigned? && self.local_image_file_name_changed?
       self.state = 'loaded'
       ZZ::Async::S3Upload.enqueue( self.id )
       logger.debug("queued for upload")
    end
  end

#GWS - short term hack to do upload and thumbnail in one step
#due to paperclip issues

  #
  # Used by the workers to load the image.
  # This call cannot be private
  #
  #GWS - currently we are bypassing the two stage process
  # of uploading and then thumbnail generation and upload
  # since paperclip is not really designed to seperate out
  # those two steps it was causing multiple uploads so we
  # are now doing the upload and thumb generation in one step
  # but still deferred and called from resque
  def upload_to_s3
    begin
      self.image = local_image.to_file
      self.local_image.clear
      self.local_image_path = ''
      self.state = 'ready'
      self.save!
      upload_batch.finish 
      logger.debug("Upload and thumbnail generation to S3 Finished")
    rescue ActiveRecord::ActiveRecordError => ex
        logger.debug("Upload to S3 Failed"+ex)
    end
  end

#  #
#  # Used by the workers to load the image.
#  # This call cannot be private
#  def upload_to_s3
#    begin
#      self.state = 'uploading'
#      self.image = local_image.to_file
#      self.save!
#      self.local_image.clear
#      self.local_image_path = ''
#      self.state = 'processing'
#      self.save!
#      logger.debug("Upload to S3 Finished")
#      ZZ::Async::GenerateThumbnails.enqueue( self.id )
#    rescue ActiveRecord::ActiveRecordError => ex
#        logger.debug("Upload to S3 Failed"+ex)
#    end
#  end

#GWS temporarily turned off - changed upload_to_s3 to do the work
#until we decide what to do about paperclip usage
#this caused a second full file upload and issues with bucket
#being different due to two stage process
  def generate_thumbnails
    begin
     self.image.reprocess!
     self.state = 'ready'
     self.save!
     upload_batch.finish 
    rescue ActiveRecord::ActiveRecordError => ex
        logger.debug("Thumbnail generation failed!" + ex)
    end
    logger.debug("Thumbnail generation Finished")   
   end

  def new?
      self.state == 'new'
  end

  def assigned?
    self.state == 'assigned'
  end

  def loaded?
    self.state == 'loaded'
  end

  def uploading?
    self.state == 'uploading'
  end

  def processing?
    self.state == 'processing'
  end

  def ready?
    self.state == 'ready'
  end

  def thumb_url
    set_s3bucket
    image.url(:thumb)
  end

  def thumb_path
    set_s3bucket
    image.path(:thumb)
  end

  def medium_url
    set_s3bucket
    image.url(:medium)
  end

  def set_s3bucket
    image.instance_variable_set '@bucket', self.image_bucket unless self.image_bucket.nil?
  end

  def self.generate_source_guid(url)
     Digest::MD5.hexdigest(url)
  end

  def substitute_source_urls
    self.source_thumb_url = self.source_thumb_url.gsub(':photo_id', self.id) if self.source_thumb_url
    self.source_screen_url =  self.source_screen_url.gsub(':photo_id', self.id) if self.source_screen_url
  end

  def metadata
    if photo_info
      JSON.parse(photo_info.metadata)
    end
  end

  def metadata=(value_hash)
    photo_info = PhotoInfo.new unless photo_info
    photo_info.metadata = value_hash.to_json
  end

# detect if our source file has changed
  def image_changed?
    self.image_file_size_changed? ||
    self.image_file_name_changed? ||
    self.image_content_type_changed? ||
    self.image_updated_at_changed?
  end


  # handle Nginx upload_module params
  def fast_local_image=(fast_local_params)
    # to prevent paperclip from copying the nginx tmp file onto another tmpfile
    # we use ZZ::NginxTempfile which overloads to_tempfile() and returns a file itself instead of a new tempfile.
    if fast_local_params
      #fast_local_params['original_name']
      #fast_local_params['content_type']
      self.local_image = ZZ::NginxTempfile.new( fast_local_params['filepath'])
    end
  end

end


