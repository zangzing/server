# == Schema Information
# Schema version: 60
#
# Table name: photos
#
#  id                       :integer         not null, primary key
#  album_id                 :integer
#  user_id                  :integer
#  agent_id                 :string(255)
#  state                    :string(255)     default("new")
#  caption                  :text
#  headline                 :text
#  capture_date             :datetime
#  suspended                :boolean
#  metadata                 :text
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  local_image_file_name    :string(255)
#  local_image_content_type :string(255)
#  local_image_file_size    :integer
#  local_image_updated_at   :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

#
# Photo Model
# © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
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
# - Using an after_save callback an async call to upload_to_s3 is queued using delayed_job.
# - When the queued call is processed, the image attribute is set to local_image triggering paperclip
#   to store and process image. The image attachment is set to store in S3 with styles.
# - local_image is set to nil never to be used again =)
#
# PHOTO STATE DEFINITION AND TRANSITIONS
# -new: Default when created, has not been assigned to a photo or server
# -assigned: The photo has been created by an agent and has been assigned to it. Its waiting to be updated with an image
# -loaded: The photo has been updated with an image and is waiting to be processed
# -processing: The photo has been taken for the processing queue and its being processed
# -ready: The photo has been processed and moved to permanent storage. It is ready to use
# -deleted: The photo has been deleted and its waiting to be removed from storage.
#
# Once a photo goes assigned it can only be updated with a valid image. When successful it goes loaded
# Only an assigned photo can be updated. Photos in any other state cannot be updated.
#
# NOTES:
# The paperclip default url is used to display a temporary graphic while the local_image is processed.
# Code to accelerate a local development server was added and it may be removed for production TODO:
#

require 'paperclip'
require 'delayed_job'


class Photo < ActiveRecord::Base
  usesguid
  belongs_to :album
  belongs_to :user


  # for development do sync load  TODO:May be removed for production
  # before_update :syncload_if_development

  #
  after_validation_on_create :set_to_assigned;

  # Set up an async call for Processing and Upload to S3
  after_update :queue_upload_to_s3
  

  # used to receive image and queue for processing. User never sees this image. Paperclip defaults are local no styles
  has_attached_file :local_image

  # This is the image that will be used most of the time
  # Set image storage options for paperclip based on the environment the app is running in
  image_options ||= {}
  image_options[:styles] ||= { :medium =>"600x400>", :thumb   => "100x100#" }
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


  validates_presence_of             :album_id, :user_id

  
  validates_attachment_presence     :local_image,{
                                    :message => "file must be specified",
                                    :if =>  :assigned?
                                    }
  validates_attachment_size         :local_image,{
                                    :less_than => 10.megabytes,
                                    :message => "must be under 5 Megs",
                                    :if =>  :assigned?
                                    }
  validates_attachment_content_type :local_image,{
                                    :content_type => [ 'image/jpeg', 'image/png', 'image/gif' ],
                                    :message => " must be a JPEG, PNG, or GIF",
                                    :if =>  :assigned?
                                    }

  # when retrieving a search from the DB it will always be ordered by created date descending a.k.a Latest first
  default_scope :order => 'created_at DESC'


  # Called after creation validations have cleared
  # it is called before the save but after validations have cleared
  def set_to_assigned
    self.state = 'assigned'
  end

  # If in development set image to local_image and generate styles synchronously
  # TODO: Maybe removed for production
  def syncload_if_development
    if Rails.env.development? && self.assigned?
        self.image = local_image.to_file
        self.state = 'ready'
    end
  end

  #
  # Used to queue loading and processing for async.
  #
  def queue_upload_to_s3
    unless self.state == 'ready'
      logger.info "PHOTO status upon queuing upload/processing job is  #{self.state}"
        if self.assigned?
          self.state = 'loaded'
          self.send_later(:upload_to_s3)
        else
          record.errors[:state] << "Photo is not assigned, cannot be updated"
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

  def assigned?
    self.state == 'assigned'
  end
  
  def ready?
    self.state == 'ready'
  end

  def thumb_url
    image.url(:thumb)
  end

  def thumb_path
    image.path(:thumb)
  end

  def medium_url
    image.url(:medium)
  end



end


