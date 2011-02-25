#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  usesguid
  attr_accessible :name, :privacy, :cover_photo_id

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :dependent => :destroy
  has_many :activities,       :dependent => :destroy
  has_many :upload_batches
  has_many :contributors
  
  has_friendly_id :name, :use_slug => true, :scope => :user, :reserved_words => ["photos", "shares", 'activities', 'slides_source', 'people'], :approximate_ascii => true

  # Set up an async call for managing the deleted photo from s3
  after_commit  :queue_delete_from_s3, :on => :destroy

  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50
  validates_length_of    :cover_photo_id, :is => 22, :message => "Invalid ID for cover photo must be GUID(22)", :if => :cover_photo_id_changed?


  #before_create :set_email
  attr_accessor :name_had_changed
  before_save  Proc.new { |model| model.name_had_changed = true }, :if => :name_changed?
  before_save  :cover_photo_id_valid?, :if => :cover_photo_id_changed?
  after_save   :set_email, :if => :name_had_changed
  #before_save   :set_email, :if => :new_slug_needed? #:name_changed?

  default_scope :order => "`albums`.updated_at DESC"

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden','Password' => 'password'};

  # build our base model name for this class and
  # hold onto it as a class variable since we only
  # need to generate it once.  The name built up
  # has all the support needed by ActiveModel to properly
  # fetch the singular and pluralized versions of the name
  # we do this rather than the default since we want
  # our child classes to use this classes table name
  # in other words we don't want PersonalAlbum to use the
  # personal_albums table we want it to use the 
  # albums table
  def self.model_name
    @@_model_name ||= ActiveModel::Name.new(Album)
  end


  def cover
    unless self.cover_photo_id.nil?
      if self.photos.empty?
         self.cover_photo_id = nil
         self.save
         return nil
      else
         cover_photo = self.photos.find_by_id( self.cover_photo_id )
         if cover_photo.nil?
             self.cover_photo_id = nil
             self.save
             return nil
         end
         return cover_photo
      end
    end
    self.photos.order("created_at ASC").first    
  end

  def cover=( photo )
    if photo.nil?
      self.cover_photo_id = nil;
    else
      self.cover_photo_id = photo.id 
    end
    self.save
  end

  # get an instance of the attached image helper class
  def attached_picon
    @attached_picon ||= PiconAttachedImage.new(self, "picon")
  end


  # make and update the picon
  def update_picon
      # make the picon in the local file system
      file = ZZ::Picon.make( self )

      self.picon_content_type = "image/png"
      self.picon_file_size = File.size(file.path)
      attached_picon.upload(file)

      # delete the file right now rather than waiting for GC
      file.delete() rescue nil

      self.save
  end

  #TODO: Make a pass later and clean up all related code to the generation of picons
  # for now just turn off the queueing
  def queue_update_picon
  #   ZZ::Async::UpdatePicon.enqueue( self.id )
  end

  #
  # Delete the s3 related objects in a deferred fashion
  #
  #TODO: Make a pass later and clean up all related code to the generation of picons
  # for now just turn off the queueing
  def queue_delete_from_s3
#    # if we have already uploaded to s3 go ahead and delete it since
#    # we are going away.
#    # in the unlikely event that the delete gets processed before the
#    # upload then the object itself will no longer exist which
#    # will keep the upload from ever taking place
#    # also, we can't rely on the album object itself since it won't
#    # exist by the time it gets processed.
#    if self.image_bucket
#      # get all of the keys to remove
#      keys = attached_picon.all_keys
#      ZZ::Async::S3Cleanup.enqueue(self.image_bucket, keys)
#      logger.debug("picon queued for s3 cleanup")
#    end
  end


  def picon_url
    if self.picon_path != nil
      # file comes from s3
      self.picon_path
    else
      # use local file
      "/images/folders/blank.jpg"
    end
  end

  def is_contributor?( email )
    c = self.contributors.find_by_email( email );
    if c
      return User.find_by_email_or_create_automatic( c.email, c.name )
    end
  end

  def is_user_contributor?( user )
    self.contributors.find_by_email( user.email )
  end

  def long_email
      " \"#{self.name}\" <#{short_email}>"
  end

  def short_email
      "#{self.friendly_id}.#{self.user.friendly_id}@#{Server::Application.config.album_email_host}"
  end

  def to_param #overide friendly_id's
    (id = self.id) ? id.to_s : nil
  end

private
  def cover_photo_id_valid?
    begin
      if cover_photo_id.length == 22 && cover_photo = photos.find(cover_photo_id)
        queue_update_picon if cover_photo.ready?
        return true
      end
    rescue ActiveRecord::RecordNotFound => e
       errors.add(:cover_photo_id,"Could not find photo with ID:"+cover_photo_id+" in this album")
    end
    return false
  end

  def set_email
    # Remove spaces and @
    mail_address = "#{self.friendly_id}.#{self.user.friendly_id}"
    self.connection.execute "UPDATE `albums` SET `email`='#{mail_address}' WHERE `id`='#{self.id}'" if self.id
    self.name_had_changed = false
  end

end



# this class simplifies the association of a named image
# in the database by managing the seperate fields needed and
# also interfaces to S3 for upload/download/delete
class PiconAttachedImage < AttachedImage
  # return the s3 key prefix
  def prefix
    @@prefix ||= "/p/"
  end
end

