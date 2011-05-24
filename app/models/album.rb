#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  attr_accessible :name, :privacy, :cover_photo_id, :photos_last_updated_at, :updated_at, :cache_version
  attr_accessor :change_matters

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :as => :subject, :dependent => :destroy
  has_many :activities,       :as => :subject, :dependent => :destroy
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
  validates_uniqueness_of :name, :scope => :user_id, :message => "You already have an album named \"%{value}\" please try a different name"

  before_validation   :uniquify_name, :on => :create

  before_save   :cover_photo_id_valid?, :if => :cover_photo_id_changed?

  # cache manager stuff
  after_save    :check_cache_manager_change
  after_commit  :make_create_album_activity, :on => :create
  after_commit  :notify_cache_manager
  after_commit  :notify_cache_manager_delete, :on => :destroy

  after_create  :add_creator_as_admin

  default_scope :order => "`albums`.updated_at DESC"

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden','Password' => 'password'};

  def uniquify_name
    @uname = name
    @i = 0
    @album = user.albums.find_by_name( @uname )
    until @album.nil?
      @i+=1
      @uname = "#{name} #{@i}"
      @album = user.albums.find_by_name(@uname)
    end
    self.name = @uname
  end

  def name_unique?( try_name )
    return true if try_name == name
    user.albums.find_by_name( try_name ).nil?
  end

  # build our base model name for this class and hold onto it as a class variable since we only
  # need to generate it once.  The name built up  has all the support needed by ActiveModel to properly
  # fetch the singular and pluralized versions of the name  we do this rather than the default since we want
  # our child classes to use this classes table name in other words we don't want PersonalAlbum to use the
  # personal_albums table we want it to use the albums table
  def self.model_name
    @@_model_name ||= ActiveModel::Name.new(Album)
  end


  # check to see if the change matters - we do this
  # before the commit because once it is commited we
  # no longer know what changed
  #
  def check_cache_manager_change
    self.change_matters = Cache::Album::Manager.shared.album_change_matters?(self)
    true
  end

  # We have been committed so call the album cache manager
  # to let it invalidate caches if needed.  We do this separately from
  # the change check because we must do this after the commit to
  # make sure we are not in a transaction
  def notify_cache_manager
    Cache::Album::Manager.shared.album_modified(self) if self.change_matters
    true
  end

  # We have been deleted, let the cache know.
  def notify_cache_manager_delete
    Cache::Album::Manager.shared.album_deleted(self)
    true
  end

  # never, never, never call get_next_id inside a transaction since failure of the transaction would rollback the
  # fetch of the id which could result in duplicates being used.
  #
  # This call changes the cache version that we use to invalidate the photo cache for this album.  We
  # use the id generator to ensure a unique id for each change.  One thing to note is that the id used
  # does not guarantee any kind of ordering.  It is only guaranteed to be unique.
  #
  def self.change_cache_version(album_id)
    now = Time.now
    version = BulkIdManager.next_id_for('album_cache_version')
    Album.update(album_id, :cache_version => version, :photos_last_updated_at => now, :updated_at => now)
  end

  def cache_key
    case
    when !persisted?
      "#{self.class.model_name.cache_key}/new"
    else
      "#{self.class.model_name.cache_key}/#{id}-#{self.cache_version}"
    end
  end

  # detect the state of the safe delete
  # if the deleted_at time has been set
  # we've been safe deleted
  def is_safe_deleted?
    return !self.deleted_at.nil?
  end

  # populate the covers for the given photos
  # we don't use .includes because the photos passed
  # into us here may have come from multiple queries
  # as in the albums_controller index method
  def self.fetch_bulk_covers(albums)
    cover_ids = []
    albums.each do |album|
      cover_photo_id = album.cover_photo_id
      cover_ids << cover_photo_id unless cover_photo_id.nil?
    end

    if cover_ids.empty? == false
      # now perform the bulk query
      coverPhotos = Photo.where(:id => cover_ids)

      # ok, now map these by id to cover
      coverMap = {}
      coverPhotos.each do |cover|
        coverMap[cover.id.to_s] = cover
      end

      # and finally associate them back to each album
      albums.each do |album|
        album.set_cached_cover(coverMap[album.cover_photo_id.to_s])
      end
    end
  end

  def set_cached_cover(cover)
    return if @cover_set

    if cover.nil?
      # no cover with this album, previously we
      # fetched each and every time for this case
      # I've changed this to lock down the cover
      # on the first fetch if the cover is nil
      # This changes the UI behavior because if
      # new photos are added the cover will remain the
      # same where previously it could become a different photo.
      @cover = cover_fetch
      # if you don't want the new behavior comment out the
      # following lines - keep in mind, doing so will result
      # in a less efficient system
      if @cover
        self.cover_photo_id = @cover.id
        self.save
      end
    else
      @cover = cover
    end

    @cover_set = true
  end


  # lets hold a temp copy of the cover to
  # avoid running queries multiple times
  def cover
    # we have cover set test because not sufficient to
    # just test for @cover.nil? because nil is a valid
    # condition for @cover and we don't want to go
    # back through all the logic again
    if !@cover_set
      @cover = cover_fetch
      @cover_set = true
    end
    @cover
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
            ZZ::Async::Email.enqueue( :contributor_added, self.id, email, msg )
          end
     else 
          # if the email does not have contributor role add it.
          unless acl.has_permission?( email, AlbumACL::CONTRIBUTOR_ROLE)
              acl.add_user email, AlbumACL::CONTRIBUTOR_ROLE
              Guest.register( email, 'contributor' )
              ZZ::Async::Email.enqueue( :contributor_added, self.id, email, msg )
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
      # not a contributor by  email account, could still be one via user id
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
      "#{self.friendly_id}@#{self.user.friendly_id}.#{Server::Application.config.album_email_host}"
  end
  alias :email :short_email

  def to_param #overide friendly_id's
    (id = self.id) ? id.to_s : nil
  end

  # Return true if album is private
  def private?
    self.privacy == 'password'
  end

  def make_private
    self.privacy = 'password'
  end

  # Return true if album is public
  def public?
    self.privacy == 'public'
  end

  def make_public
    self.privacy = 'public'
  end

  # Return true if album is hidden
  def hidden?
    self.privacy == 'hidden'
  end

  def make_hidden
    self.privacy = 'hidden'
  end


private
  def make_create_album_activity
    aca = CreateAlbumActivity.create( :user => self.user, :subject => self)
    self.activities << aca
  end


  def cover_photo_id_valid?
    begin
      return true if cover_photo_id.nil?
      photos.find(cover_photo_id)
      return true
    rescue ActiveRecord::RecordNotFound => e
       errors.add(:cover_photo_id,"Could not find photo with ID:"+cover_photo_id.to_s+" in this album")
    end
    return false
  end

  def add_creator_as_admin
    acl.add_user( user.id, AlbumACL::ADMIN_ROLE )
  end

  # this pulls the cover from the db
  # this should be private since internal to
  # album
  def cover_fetch
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
    # no need to custom order as default scope provides proper ordering
    # pos ASC, created_at ASC
    self.photos.first
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

