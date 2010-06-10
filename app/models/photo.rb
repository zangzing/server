# == Schema Information
# Schema version: 20100602212717
#
# Table name: photos
#
#  id                 :integer         not null, primary key
#  album_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  user_id            :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

# == Schema Information
# Schema version: 20100511235524
#
# Table name: photos
#
#  id         :integer         not null, primary key
#  album_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#


#
# ASYNC UPLOADING AND PROCESSING
#
# To improve speed of upload, the S3 backend loading and image processing is asynchronous.
# - The default state of a photo is "new"
# - The photo is uploaded and a local copy stored.
# - The local photo is stored using paperclip in the local_image attribute which is set for local storage no styles.
# - State is set to "processing". No image processing is done
# - An async call to upload_to_s3 is queued using delayed_job
# - The async call sets attribute image to local_image triggering paperclip to upload and proces images
# - The state is set to "ready" local image is set to nil never to be used again =) 
#
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
  image_options[:styles] ||= { :medium =>"300x300>", :thumb   => "100x100#" }
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
  
  default_scope :order => 'created_at DESC'

  def thumb_url
    image.url(:thumb)
  end

  def thumb_path
    image.path(:thumb)
  end

  def syncload_if_development
    if Rails.env.development?
        self.image = local_image.to_file
        self.state = 'ready'
    end
  end

  def queue_upload_to_s3
    logger.info "PHOTO status upon queuing upload/processing job is  #{self.state}"
    unless Rails.env.development?
      if self.new? && self.local_image_updated_at_changed?
        self.state = 'processing'
        self.send_later(:upload_to_s3)
      end
    end
  end

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


