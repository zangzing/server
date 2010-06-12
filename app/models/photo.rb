# == Schema Information
# Schema version: 20100610185856
#
# Table name: photos
#
#  id                       :integer         not null, primary key
#  album_id                 :integer
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  local_image_file_name    :string(255)
#  local_image_content_type :string(255)
#  local_image_file_size    :integer
#  local_image_updated_at   :datetime
#  state                    :string(255)     default("new")
#


#
# Photo Model
#
# As a first implementation images are attached to photo objects using paperclip as
# performance and customization changes are required the use of paperclip can be
# revisited or we can contribute the improvements to paperclip.
#
# The way paperclip works is:
# An image is received in a create or update request as part of a multi-part form post.
# Paperclip takes the tmp image file and moves it to its destination either locally or
# to S3. Then using the tmp file, paperclip uses imagemagick to create the required styles.
# During the whole time, the requester is kept waiting.
#
# We should investigate the possibility of using graphicmagick instead if its faster.
#
#
# ASYNC UPLOADING AND PROCESSING
#
# To improve speed of upload, the S3 backend loading and image processing is asynchronous.
# - The default state of a photo is "new"
# - The photo is uploaded and a local copy stored.
# - The local photo is stored into the local_image attachment attribute which is set for local storage no styles.
# - State is set to "processing". No image processing is done
# - Using an after_save callback an async call to upload_to_s3 is queued using delayed_job.
# - When the queued call is processed, the image attachment attribute is set to local_image triggering paperclip
#   to store and process image. The image attachment is set to store in S3 with styles.
# - The state is set to "ready" local image is set to nil never to be used again =) 
#
# NOTES:
# The paperclip default url is used to display a temporary graphic while the local_image is processed.
# Code to accelerate a local development server was added and it may be removed for production TODO:
#

require 'paperclip'
require 'delayed_job'


class Photo < ActiveRecord::Base
  belongs_to :album


  # for development do sync load
  before_save :syncload_if_development


  # Set up an asyng call for Processing and Upload to S3
  after_save :queue_upload_to_s3
  

  # used to receive image and queue for processing. User never sees this image. Paperclip defaults are local no styles
  has_attached_file :local_image

  # This is the image that will be used most of the time
  # Set image storage options for paperclip based on the environment the app is running in
  image_options ||= {}
  image_options[:styles] ||= { :medium =>"800x600>", :thumb   => "100x100#" }
  image_options[:whiny]  ||= true
  image_options[:default_url]='/images/working.png'
  unless Rails.env.development?
          #for test use S3
          image_options[:storage]  ||= :s3
          image_options[:s3_credentials] ||= "#{RAILS_ROOT}/config/s3.yml" #Config file also contains :bucket
          image_options[:path]            ||= ":attachment/:id/:style/:basename.:extension"
  end
  # For development environment, use the default filesystem 

  has_attached_file :image, image_options


  validates_presence_of             :album_id
  validates_attachment_presence     :local_image,{
                                    :message => "file must be specified",
                                    :if =>  :new?
                                    }
  validates_attachment_size         :local_image,{
                                    :less_than => 5.megabytes,
                                    :message => "must be under 5 Megs",
                                    :if =>  :new?
                                    }
  validates_attachment_content_type :local_image,{
                                    :content_type => [ 'image/jpeg', 'image/png', 'image/gif' ],
                                    :message => " must be a JPEG, PNG, or GIF",
                                    :if =>  :new?
                                    }

  # when retrieving a search from the DB it will always be ordered by created date descending a.k.a Latest first
  default_scope :order => 'created_at DESC'

  def thumb_url
    image.url(:thumb)
  end

  def thumb_path
    image.path(:thumb)
  end

  def medium_url
    image.url(:medium)
  end

  # If in development set image to local_image and generate styles synchronously
  def syncload_if_development
    if Rails.env.development?
        self.image = local_image.to_file
        self.state = 'ready'
    end
  end

  #
  # Used to queue loading and processing for async.
  def queue_upload_to_s3
    logger.info "PHOTO status upon queuing upload/processing job is  #{self.state}"
    unless Rails.env.development?
      if self.new? && self.local_image_updated_at_changed?
        self.state = 'processing'
        self.send_later(:upload_to_s3)
      end
    end
  end

  #
  # Used by the workers to load the image.
  # This call cannot be privates
  def upload_to_s3
      self.state = 'processing'
      self.image = local_image.to_file
      self.local_image.clear
      self.state = 'ready'
      self.save!
  end

  def new?
      self.state == 'new'
  end

  def ready?
    self.state == 'ready'
  end
end


