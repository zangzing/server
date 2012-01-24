#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
    extend PrettyUrlHelper

  attr_accessible :name, :privacy, :cover_photo_id, :photos_last_updated_at, :updated_at, :cache_version, :photos_ready_count,
                  :stream_to_email, :stream_to_facebook, :stream_to_twitter, :who_can_download, :who_can_buy, :who_can_upload, :user_id, :for_print

  attr_accessor :change_matters, :my_role

  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :as => :subject, :dependent => :destroy
  has_many :activities,       :as => :subject, :dependent => :destroy
  has_many :upload_batches

  has_many :like_mees,      :foreign_key => :subject_id, :class_name => "Like"
  has_many :likers,         :through => :like_mees, :class_name => "User",  :source => :user

  has_many :users_who_like_albums_photos, :class_name => "User", :finder_sql =>
          'SELECT u.* ' +
          'FROM photos p, likes l, users u '+
          'WHERE '+
          'l.subject_type = "P" AND '+
          'l.subject_id = p.id AND '+
          'p.album_id = #{id} AND '+
          'l.user_id = u.id '+
          'GROUP BY u.id '+
          'ORDER BY u.first_name DESC'


  PUBLIC   = 'public'
  HIDDEN   = 'hidden'
  PASSWORD = 'password'
  PRIVACIES = [PUBLIC, HIDDEN, PASSWORD]
  validates_inclusion_of  :privacy, :in => PRIVACIES

  #constants for Album.who_can_upload and Album.who_can_download and Albun.who_can_buy
  WHO_EVERYONE      = 'everyone'
  WHO_VIEWERS       = 'viewers'
  WHO_CONTRIBUTORS  = 'contributors'
  WHO_OWNER         = 'owner'
  WHO_CAN = [WHO_EVERYONE, WHO_VIEWERS, WHO_CONTRIBUTORS, WHO_OWNER]
  validates_inclusion_of  :who_can_download, :in => WHO_CAN
  validates_inclusion_of  :who_can_upload, :in => WHO_CAN
  validates_inclusion_of  :who_can_buy, :in => WHO_CAN

  DEFAULT_NAME = 'New Album'

  RESERVED_NAMES = ["photos", "shares", 'activities', 'slides_source', 'people', 'activity']
  has_friendly_id :name, :use_slug => true, :scope => :user, :reserved_words => RESERVED_NAMES, :approximate_ascii => true

  validates_presence_of  :user_id
  validates_presence_of  :name, :message => "Your album name cannot be blank"
  validates_length_of    :name, :maximum => 50, :message => "Album name cannot be longer than 50 characters"
  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false, :message => "You already have an album named \"%{value}\" please try a different name"

  before_validation   :uniquify_name, :on => :create
  before_validation   'self.name.strip!', :if => :name_changed?

  before_save   :cover_photo_id_valid?, :if => :cover_photo_id_changed?

  # cache manager stuff
  after_save    :check_cache_manager_change
  after_commit  :make_create_album_activity, :on => :create
  after_commit  :notify_cache_manager
  after_commit  :after_destroy_cleanup, :on => :destroy

  after_create  :add_creator_as_admin

  default_scope :order => "`albums`.updated_at DESC"



  # safe way to find albums that prevents users from
  # discovering a hidden albums by guessing its default name
  def self.safe_find(user, album_id)
    album = user.albums.find(album_id)

    # if id starts with the default album name, then we need to check if the album name
    # is still the default or if it has changed
    if album_id.to_s.starts_with?(Album::DEFAULT_NAME.parameterize)

      # need to strip off the FriendlyId slug version/sequence number
      # which comes after the "--" and then compare
      if album.name.parameterize != album_id.split('--')[0]
        raise(ActiveRecord::RecordNotFound)
      end
    end

    return album
  end



  # need to override basic destroy behavior since
  # we have to know when we are being destroyed in
  # dependent photos so we don't perform unnecessary cache changes
  # we can't simply set an instance variable because
  # if you try to fetch the photo.album when it is being
  # deleted it will fetch a new one from the db and
  # will not be the same object that we are using here
  #
  # So, we need to resort to using a thread local that
  # holds the state so we can get to it from within the
  # child.
  #
  def destroy
    Thread.current[:the_album_being_deleted] = self
    super
  rescue Exception => ex
    raise ex
  ensure
    Thread.current[:the_album_being_deleted] = nil
  end

  # using the thread local storage determine
  # if the given album_id is being deleted
  def self.album_being_deleted?(album_id)
    album = Thread.current[:the_album_being_deleted]
    return false if album.nil?
    album.id == album_id
  end

  def skip_duplicate_name_check=(val)
    @skip_duplicate_name_check = val
  end

  def skip_duplicate_name_check?
    @skip_duplicate_name_check ||= false
  end

  def uniquify_name
    return if skip_duplicate_name_check?
    @uname = name
    @i = 0

    @album = user.albums.find_by_name( @uname )
    until @album.nil? && !RESERVED_NAMES.index(@uname.downcase)
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
    if self.destroyed? == false
      Cache::Album::Manager.shared.album_modified(self) if self.change_matters
    end
    true
  end

  # We have been deleted, let the cache know and the acl manager
  def after_destroy_cleanup
    Cache::Album::Manager.shared.album_deleted(self)
    acl.remove_acl    # remove the acl associated with us
    true
  end

  # never, never, never call get_next_id inside a transaction since failure of the transaction would rollback the
  # fetch of the id which could result in duplicates being used.
  #
  # This call changes the cache version that we use to invalidate the photo cache for this album.  We
  # use the id generator to ensure a unique id for each change.  One thing to note is that the id used
  # does not guarantee any kind of ordering.  It is only guaranteed to be unique.
  #
  # Note: we rely on the update causing the after_ notifications to trigger
  def self.change_cache_version(album_id)
    version = BulkIdManager.next_id_for('album_cache_version')
    now = Time.now
    Album.update(album_id, :cache_version => version, :photos_last_updated_at => now, :updated_at => now)
  end

  # this is used for ETAG generation only
  def cache_key
    case
    when !persisted?
      "#{self.class.model_name.cache_key}/new"
    else
      "#{self.class.model_name.cache_key}/#{id}-#{self.cache_version_key}"
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

    cover_map = {}
    if cover_ids.empty? == false
      # now perform the bulk query
      cover_photos = Photo.where(:id => cover_ids)

      # ok, now map these by id to cover
      cover_photos.each do |cover|
        cover_map[cover.id] = cover
      end
    end
    # and finally associate them back to each album
    albums.each do |album|
      album.set_cached_cover(cover_map[album.cover_photo_id])
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

  # this returns a versioned key that handles schema chagnes
  # to the underlying photo hash
  def cache_version_key
    "#{Photo.hash_schema_version}.#{self.cache_version}"
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

  def add_contributor( email)
     user = User.find_by_email( email )
     if user
          #if user does not have contributor role, add it
          unless acl.has_permission?( user.id, AlbumACL::CONTRIBUTOR_ROLE)
            acl.add_user user.id, AlbumACL::CONTRIBUTOR_ROLE
            InviteActivity.create( :user => self.user,
                                   :subject => self,
                                   :invite_kind => InviteActivity::CONTRIBUTE,
                                   :album_id => self.id,
                                   :invited_user_id => user.id )
            #reciprocal activity to go in invited_user's activity list.
            InviteActivity.create( :user => user,
                                   :subject => user,
                                   :invite_kind => InviteActivity::CONTRIBUTE,
                                   :album_id => self.id,
                                   :invited_user_id => user.id )
          end
     else 
          # if the email does not have contributor role add it.
          unless acl.has_permission?( email, AlbumACL::CONTRIBUTOR_ROLE)
              acl.add_user email, AlbumACL::CONTRIBUTOR_ROLE
              InviteActivity.create!( :user => self.user,
                                     :subject => self,
                                     :invite_kind => InviteActivity::CONTRIBUTE,
                                     :album_id => self.id,
                                     :invited_user_email => email )
             # Guest.register( email, 'contributor' )
          end
     end
  end

  # Adds the AlbumACL::VIEWER_ROLE to the user associated to this email
  # or to the email itself if there is no user yet.
  # If the email/user already has view permissions (through VIEWER or other
  # ROLES) nothing happen
  def add_viewer( email )
     user = User.find_by_email( email )
     if user
          #is user does not have vie permissions, add them
          unless acl.has_permission?( user.id, AlbumACL::VIEWER_ROLE)
            acl.add_user user.id, AlbumACL::VIEWER_ROLE
            InviteActivity.create( :user => self.user,
                                   :subject => self,
                                   :invite_kind => InviteActivity::VIEW,
                                   :album_id => self.id,
                                   :invited_user_id => user.id )
            #reciprocal activity to go in invited_user's activity list.
            InviteActivity.create( :user => user,
                                   :subject => user,
                                   :invite_kind => InviteActivity::VIEW,
                                   :album_id => self.id,
                                   :invited_user_id => user.id )
          end
     else
          # if the email does not have view permissions add  them
          unless acl.has_permission?( email, AlbumACL::VIEWER_ROLE)
              acl.add_user email, AlbumACL::VIEWER_ROLE
              InviteActivity.create!( :user => self.user,
                                     :subject => self,
                                     :invite_kind => InviteActivity::VIEW,
                                     :album_id => self.id,
                                     :invited_user_email => email )
          end
     end
  end


  def remove_contributor( id )
     acl.remove_user( id ) if contributor? id
  end

  def remove_viewer( id )
     acl.remove_user( id ) if viewer? id
  end


  def viewer?( id )
      if private?
        acl.has_permission?( id, AlbumACL::VIEWER_ROLE)
      else
        true
      end
  end

  #true if the id has viewer role or higher 
  def viewer_in_group?( id )
     acl.has_permission?( id, AlbumACL::VIEWER_ROLE)
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
  # If album is set to allow anyone to contribute, it will skip the contributor
  # check and always create a new user if necessary
  def get_contributor_user_by_email( email )
    user = nil

    if self.everyone_can_contribute?
      # this is open album, so go ahead and create anonymouse user if necessary
      user = User.find_by_email_or_create_automatic( email, "Anonymous", false )
    elsif contributor?( email )
      # was in the ACL via email address so turn into real user, no need to test again as we already passed
      user = User.find_by_email_or_create_automatic( email, "Anonymous", false )
    else
      # not a contributor by email account, could still be one via user id
      user = User.find_by_email( email )

      if contributor?(user.id) == false
        # clear out the user to indicate not valid
        user = nil  
      end
    end
    user
  end

  #Returns album contributors if exact = true, only the ones with CONTRIBUTOR_ROLE not equivalent ROLES are returned
  def contributors( exact = false)
    acl.get_users_with_role( AlbumACL::CONTRIBUTOR_ROLE, exact )
  end

  #Returns album contributors if exact = true, only the ones with CONTRIBUTOR_ROLE not equivalent ROLES are returned
  def viewers( exact = false)
    acl.get_users_with_role( AlbumACL::VIEWER_ROLE, exact )
  end


  # checks if user can buy photos from the album
  # in the case of a guest, user param may be nil
  def can_user_buy_photos?(user)
    return true if who_can_buy == WHO_EVERYONE
    return true if who_can_buy == WHO_OWNER && user && admin?(user.id)
    return true if who_can_buy == WHO_VIEWERS && user && viewer?(user.id)

    return false
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
    self.privacy == PASSWORD
  end

  def make_private
    self.privacy = PASSWORD
  end

  # Return true if album is public
  def public?
    self.privacy == PUBLIC
  end

  def make_public
    self.privacy = PUBLIC
  end

  # Return true if album is hidden
  def hidden?
    self.privacy == HIDDEN
  end

  def can_user_edit?( user )
    return false if user.nil?
    admin?(user.id )
  end

  def can_user_download?( user )
    if user.nil?
      # check conditions for no user given
      return false if private?
      return true if who_can_download == WHO_EVERYONE
    else
      user_id = user.id
      #album owner can always download
      return true if user_id == self.user_id

      case who_can_download
        when WHO_EVERYONE
          return true
        when WHO_OWNER
          return true if admin?(user_id)
        when WHO_VIEWERS
          return true if viewer_in_group?( user_id ) #check ACL even if it is public
      end
    end
    false
  end

  def can_user_contribute?( user )
    return true  if everyone_can_contribute?
    return false if user.nil?  #only contributors can download
    return contributor?( user.id )
  end

  def make_hidden
    self.privacy = HIDDEN
  end

  # for private albums we always return false
  # since invite only is implied - for hidden
  # and public we check the who_can_upload status
  def everyone_can_contribute?
    return false if private?
    self.who_can_upload == WHO_EVERYONE
  end

  def to_json_lite()
    # since the to_json method of an active record cannot take advantage of the much faster
    # JSON.fast_generate, we pull the object apart into a hash and generate from there.
    # In benchmarks Greg Seitz found that the generate method is 10x faster, so for instance the
    # difference between 10000/sec and 1000/sec
    JSON.fast_generate( self.attributes )
  end

  # update the photo counters for a given albums
  # in a single update
  def self.update_photo_counters(album_id)
    photo_count = Photo.count('id', :conditions => "album_id = #{album_id}")
    ready_count = Photo.count('id', :conditions => "album_id = #{album_id} AND state = 'ready'")
    connection.execute("UPDATE albums SET photos_count = #{photo_count}, photos_ready_count = #{ready_count} WHERE id = #{album_id};")
  end

  # this is here so we can manually update the photos
  # counts - the server should not be running
  # when this is called to ensure that we end up
  # with accurate counts
  def self.update_all_photo_counters
    # set the current counts
    albums = Album.all
    albums.each do |album|
      update_photo_counters(album.id)
    end

    albums.count
  end

  # update the photos ready counter by the specified amount
  # can be negative or positive
  def self.update_photos_ready_count(album_id, amount)
    Album.update_counters album_id, :photos_ready_count => amount
  end

  # This tracks the version of the data
  # provided in a single hashed album for
  # our api usage.  If you make a change
  # to the albums_to_hash method below
  # make sure you bump this version so
  # we invalidate the browsers cache for
  # old items.
  def self.hash_schema_version
    'v9'
  end

  # this method returns the album as a map which allows us to perform
  # very fast json conversion on it - it also represents the standard
  # api response format for an album
  #
  # albums - the array of albums to convert
  #
  # if you api wants to add or remove data it should start by calling
  # this and make the necessary changes since we want a consistent
  # set of fields
  def self.albums_to_hash(albums)
    fast_albums = []

    if albums.empty?
      # return a simple array data type
      return fast_albums
    end

    # first grab all the cover photos in one query
    # this populates the albums in place
    Album.fetch_bulk_covers(albums)

    # now fetch all the user_id and user names in one query
    user_ids = albums.map(&:user_id).uniq
    users = User.select('id,username').where(:id => user_ids)
    # and set up the map to track them
    user_id_to_name = {}
    users.each do |user|
      user_id_to_name[user.id] = user.username
    end

    albums.each do |album|
      album_cover = album.cover
      album_id = album.id
      album_name = album.name
      album_friendly_id = album.friendly_id

      # fetch the username from our local cache
      album_user_id = album.user_id
      album_user_name = user_id_to_name[album_user_id]

      # prep for substitution
      cover_base = nil
      cover_sizes = nil
      cover_id = nil
      cover_date  = album.created_at.to_i #default value for empty albums
      if album_cover && album_cover.ready?
        cover_date = album_cover.capture_date unless album_cover.capture_date.nil?
        cover_base = album_cover.base_subst_url
        cover_id = album_cover.id
        if cover_base
          # ok, photo is ready so include sizes map
          cover_sizes = {
              :thumb            => album_cover.suffix_based_on_version(AttachedImage::THUMB),
              :iphone_cover     => album_cover.suffix_based_on_version(AttachedImage::IPHONE_COVER),
              :iphone_cover_ret => album_cover.suffix_based_on_version(AttachedImage::IPHONE_COVER_RET)
          }
        end
      end

      is_profile_album = album.type == 'ProfileAlbum'
      if is_profile_album and album_cover.nil?
        c_url = ProfileAlbum.default_profile_album_url
      else
        c_url =  album_cover.nil? ? nil : album_cover.thumb_url  #todo: this should only return non nil if cover_base is nil
      end

      hash_album = {
          :id => album_id,
          :name => album_name,
          :email => album.email,
          :user_name => album_user_name,
          :user_id => album_user_id,
          :album_path => album_pretty_path(album_user_name, album_friendly_id),
          :profile_album => is_profile_album,
          :c_url =>  c_url,
          :cover_id => cover_id,
          :cover_base => cover_base,
          :cover_sizes => cover_sizes,
          :cover_date => cover_date.to_i,
          :photos_count => album.photos_count,
          :photos_ready_count => album.photos_ready_count,
          :cache_version => album.cache_version_key,
          :updated_at => album.updated_at.to_i,
          :my_role => album.my_role, # valid values are Viewer, Contrib, Admin
          :privacy => album.privacy,
          :all_can_contrib => album.everyone_can_contribute?,
          :who_can_download => album.who_can_download, #Valid values are viewers, owner, everyone
          :who_can_upload => album.who_can_upload,
          :who_can_buy => album.who_can_buy,
          :stream_to_facebook => album.stream_to_facebook,
          :stream_to_twitter => album.stream_to_twitter,
          :stream_to_email => album.stream_to_email,
      }
      fast_albums << hash_album
    end

    return fast_albums
  end

  # single album hash
  def as_hash
    Album.albums_to_hash([self])[0]
  end

private
  def make_create_album_activity
    return if self.is_a?( ProfileAlbum )
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
    @@prefix ||= "p/"
  end
end

