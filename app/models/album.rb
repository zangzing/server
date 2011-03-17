#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  attr_accessible :name, :privacy, :cover_photo_id, :photos_last_updated_at, :updated_at

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :as => :subject, :dependent => :destroy
  has_many :activities,       :dependent => :destroy
  has_many :upload_batches

  has_many :like_mees,      :foreign_key => :subject_id, :class_name => "Like"
  has_many :likers,         :through => :like_mees, :class_name => "User",  :source => :user

  has_many :users_who_like_albums_photos, :class_name => "User", :finder_sql =>
          'SELECT u.* ' +
          'FROM photos p, likes l, users u WHERE '+
          'l.subject_type = "P" AND l.subject_id = p.id AND p.album_id = #{id} '+
          'AND l.user_id = u.id ORDER BY u.first_name DESC'




  has_friendly_id :name, :use_slug => true, :scope => :user, :reserved_words => ["photos", "shares", 'activities', 'slides_source', 'people'], :approximate_ascii => true


  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50


  
  attr_accessor :name_had_changed
  before_save   Proc.new { |model| model.name_had_changed = true }, :if => :name_changed?
  before_save   :cover_photo_id_valid?, :if => :cover_photo_id_changed?
  after_save    :set_email, :if => :name_had_changed

  after_create  :add_creator_as_admin


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


  # generate a quick touch without having to
  # instantiate an object
  def self.touch_photos_last_updated(album_id)
    now = Time.now
    Album.update(album_id, :photos_last_updated_at => now, :updated_at => now)
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


  def picon_url
    if self.picon_path != nil
      # file comes from s3
      self.picon_path
    else
      # use local file
      "/images/folders/blank.jpg"
    end
  end

  def acl
    @acl ||= AlbumACL.new( self.id )
  end

  def add_contributor( email, msg='' )

     user = User.find_by_email( email )
     if user
          #if user does not have contributor role, add it
          unless acl.has_permission?( user.id, AlbumACL::CONTRIBUTOR_ROLE)
            acl.add_user user.id, AlbumACL::CONTRIBUTOR_ROLE
            ZZ::Async::Email.enqueue( :contributors_added, self.id, email, user.id, msg )
          end
     else
          # if the email does not have contributor role add it.
          unless acl.has_permission?( email, AlbumACL::CONTRIBUTOR_ROLE)
              acl.add_user email, AlbumACL::CONTRIBUTOR_ROLE
              ZZ::Async::Email.enqueue( :contributors_added, self.id, email, nil, msg )
          end
     end
  end

  # Adds the AlbumACL::VIEWER_ROLE to the user associated to this email
  # or to the email itself if there is no user yet.
  # If the email/user already has view permissions (through VIEWER or other
  # ROLES) nothing happens
  def add_viewer( email )
     user = User.find_by_email( email )
     if user
          #is user does not have vie permissions, add them
          unless acl.has_permission?( user.id, AlbumACL::VIEWER_ROLE)
            acl.add_user user.id, AlbumACL::VIEWER_ROLE
          end
     else
          # if the email does not have view permissions add  them
          unless acl.has_permission?( email, AlbumACL::VIEWER_ROLE)
              acl.add_user email, AlbumACL::VIEWER_ROLE
          end
     end
  end


  def remove_contributor( id )
     acl.remove_user( id ) if contributor? id
  end

  def viewer?(id)
    if private?
      acl.has_permission?( id, AlbumACL::VIEWER_ROLE)
    else
      true
    end
  end

  # Returns true if id has contributor role or equivalent
  def contributor?( id )
    acl.has_permission?( id, AlbumACL::CONTRIBUTOR_ROLE)
  end

  # Returns true if id has admin role or equivalent
  def admin?( id )
    acl.has_permission?( id, AlbumACL::ADMIN_ROLE)
  end



  # Checks of email is that of a contributor and returns user
  # If the email is that of a valid contributor, it will return the
  # user object for the contributor.
  # It will return nil if the email is not that of a contributor.
  def get_contributor_user_by_email( email )
    user = nil
    if contributor?( email )
      # was in the ACL via email address so turn into real user, no need to test again as we already passed
      user = User.find_by_email_or_create_automatic( email, "Anonymous" )
    else
      # not a contributor by the email account, could still be one via user id
      user = User.find_by_email( email )
      if user && contributor?(user.id) == false
        user = nil  # clear out the user to indicate not valid
      end
    end
    user
  end

  #Returns album contributors if exact = true, only the ones with CONTRIBUTOR_ROLE not equivalent ROLES are returned
  def contributors( exact = false)
    acl.get_users_with_role( AlbumACL::CONTRIBUTOR_ROLE, exact )
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

  # Return true if album is private
  def private?
    self.privacy == 'password'
  end

  # Return true if album is public
  def public?
    self.privacy == 'public'
  end

  # Return true if album is hidden
  def hidden?
    self.privacy == 'hidden'
  end

private
  def cover_photo_id_valid?
    begin
      photos.find(cover_photo_id)
      return true
    rescue ActiveRecord::RecordNotFound => e
       errors.add(:cover_photo_id,"Could not find photo with ID:"+cover_photo_id.to_s+" in this album")
    end
    return false
  end

  def set_email
    # Remove spaces and @
    mail_address = "#{self.friendly_id}.#{self.user.friendly_id}"
    self.connection.execute "UPDATE `albums` SET `email`='#{mail_address}' WHERE `id`='#{self.id}'" if self.id
    self.name_had_changed = false
  end

  def add_creator_as_admin
    acl.add_user( user.id, AlbumACL::ADMIN_ROLE )
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

