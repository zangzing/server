#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

# "automatic" users are created when a contributor adds photos by email but does not have
# an account

class User < ActiveRecord::Base
  attr_writer      :name
  attr_accessor    :old_password, :reset_password
  attr_accessible  :email, :name, :first_name, :last_name, :username,  :password, :old_password, :automatic, :profile_photo_id

  has_many :albums,              :dependent => :destroy

  #things I like, join with likes table
  has_many :likes
  has_many :liked_albums,         :through => :likes, :class_name => "Album", :source => :subject,  :conditions => "likes.subject_type = 'A' AND albums.completed_batch_count > 0"
  has_many :liked_public_albums,  :through => :likes, :class_name => "Album", :source => :subject,  :conditions => "likes.subject_type = 'A' AND albums.completed_batch_count > 0 AND albums.privacy = 'public'"
  has_many :liked_users,          :through => :likes, :class_name => "User",  :source => :subject,  :conditions => { 'likes.subject_type' => 'U'}
  has_many :liked_photos,         :through => :likes, :class_name => "Photo", :source => :subject,  :conditions => { 'likes.subject_type' => 'P'}

  # pull in all public albums for the users this user likes
  has_many :liked_users_public_albums,   :class_name => "Album", :finder_sql =>
      'SELECT a.* ' +
      'FROM albums a, likes l, users u ' +
      'WHERE l.user_id = #{id} AND l.subject_id = u.id AND u.id = a.user_id ' +
      'AND l.subject_type = "U" AND a.privacy = "public" AND a.completed_batch_count > 0 AND a.type <> "ProfileAlbum" ' +
      'ORDER BY a.updated_at DESC'

  #Reverse lookup join likers ar those who like me
  has_many :like_mees,            :foreign_key => :subject_id, :class_name => "Like"
  has_many :likers,               :through => :like_mees, :class_name => "User",  :source => :user

  has_one  :profile_album,       :dependent => :destroy, :autosave => true
  has_one  :preferences,         :dependent => :destroy, :class_name => "UserPreferences", :autosave => true
  has_many :identities,          :dependent => :destroy
  has_many :contacts,            :through => :identities, :class_name => "Contact"

  has_many :shares
  has_many :activities,          :dependent => :destroy
  has_many :photos
  has_many :upload_batches
  has_many :client_applications, :dependent => :destroy 
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]


  has_many :followers, :class_name => 'Follow', :foreign_key => 'followed_id'
  has_many :follower_users, :through => :followers, :source => :follower
  has_many :follows,   :class_name => 'Follow', :foreign_key => 'follower_id', :dependent => :destroy
  has_many :follows_users, :through => :follows,  :source => :followed

    
  # This delegates all authentication details to authlogic
  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.login_field = :email
    c.validate_login_field = false
    c.disable_perishable_token_maintenance=true;
  end

  before_save    :split_name
  before_create  :make_profile_album
  before_create  :build_preferences
  after_commit   :update_acls_with_id
  after_commit   :like_mr_zz

  validates_presence_of   :name,      :unless => :automatic?
  validates_presence_of   :username,  :unless => :automatic?
  validates_format_of     :username,  :with => /^[a-z0-9]+$/, :message => 'Should contain only lowercase alphanumeric characters', :unless => :automatic?
  validates_uniqueness_of :username,  :message => "Has already been taken", :unless => :automatic?
  validates_presence_of   :email
  validates_length_of     :password, :within => 6..40, :if => :require_password?, :message => "must be between 6 and 40 characters long"
  validate :old_password_valid?, :on => :update, :unless => :reset_password

  has_friendly_id :username

  Identity::UI_INFO.keys.each do |service_name|
    define_method("identity_for_#{service_name}") do
      identity = self.identities.find(:first, :conditions => {:identity_source => service_name.to_s})
      #identity = self.identities.create(:identity_source => service_name.to_s) unless identity
      unless identity
        identity = Identity.factory(self, service_name.to_s)
      end
      identity
    end
  end


  # make the profile album
  def make_profile_album
    p = ProfileAlbum.new()
    p.make_private
    self.profile_album = p
  end

  def self.find_by_email_or_create_automatic( email, name='' )
    user = User.find_by_email( email );
    if user.nil?
      mail_name = username = email.split('@').first
      i = 1
      begin
        username = "#{mail_name}#{i}"
        i += 1
      end while User.find_by_username(username)
      name = ( name == '' ? email.split('@')[0] : name )
      #user not fount create an automatic user with a random password
      user = User.new(  :automatic => true,
                           :email => email,
                           :name => name,
                           :username => username,  #username is in DB index, so '' won't work
                           :password => UUIDTools::UUID.random_create.to_s);
      user.reset_perishable_token
      user.save!
    end
    return user
  end

  # overrides any existing error messages with the
  # one passed.
  def set_single_error(field, msg)
    @errors = ActiveModel::Errors.new(self)
    self.errors.add(field, msg)
  end

  def has_valid_identity?( service_name )
    id = self.identities.find_by_identity_source( service_name.to_s )
    if id && id.credentials_valid?  # Return true if there is an id and its credentials are valid
      return id
    else
      return false
    end
  end

  # automatic users were created by the system from contributors emailing photos or OAuth login i.e. FaceBookConnect
  def automatic?
    self.automatic
  end

  # Generates a new perishable token for the notifier to use in a password reset request
  def deliver_password_reset_instructions!
      reset_perishable_token!
      ZZ::Async::Email.enqueue( :password_reset_instructions, self.id )
  end

  def deliver_activation_instructions!
      reset_perishable_token!
      # We may want to delay this action but we need to do it fast, maybe to its own queue!
      ZZ::Async::Email.enqueue( :activation_instructions, self.id )
  end

  def deliver_welcome!
     reset_perishable_token!
     ZZ::Async::Email.enqueue( :welcome, self.id )
  end

  def admin?
    @is_admin ||= lambda {
      acl = SystemRightsACL.singleton
      acl.has_permission?(self.id, SystemRightsACL::ADMIN_ROLE)
    }.call
  end

  def support_hero?
      @is_admin ||= lambda {
        acl = SystemRightsACL.singleton
        acl.has_permission?(self.id, SystemRightsACL::SUPPORT_HERO_ROLE)
      }.call
  end

  def moderator?
       @is_admin ||= lambda {
         acl = SystemRightsACL.singleton
         acl.has_permission?(self.id, SystemRightsACL::MODERATOR_ROLE)
       }.call
  end



  def name
    @name ||= [first_name, last_name].compact.join(' ')
  end

  def activate!
      self.active = true
      save
  end

  def self.find_by_email_or_username(login)
    find_by_email(login) || find_by_username(login)
  end

  def profile_photo_id=(id)
    if profile_album.nil?
      make_profile_album
    end

    if id && id.is_a?(String) && id.length <= 0
      profile_album.profile_photo_id=nil
    else
      profile_album.profile_photo_id=id
    end
    profile_album.save
  end
  
  def profile_photo_id
      create_profile_album if profile_album.nil?  
      @profile_photo_id ||= profile_album.profile_photo_id
  end

  def profile_photo_url
      create_profile_album if profile_album.nil?    
      @profile_photo_url ||= profile_album.profile_photo_url
  end

  def formatted_email
      "#{self.name}<#{self.email}>"
  end


  private
  def old_password_valid?
    if require_password? && !new_record? && !valid_password?(old_password)
      errors.add(:old_password, "You old password does not match our records")
      false
    else
      true
    end
  end

  def require_password?
    # only require password if password field changed in an update or if resseting your password
    password_changed? || (crypted_password.blank? && !new_record?) || reset_password
  end


  def split_name
      unless name.nil?
        names = name.split
        self.last_name = names.pop
        self.first_name = names.join(' ')
      end
  end

  # Replaces any occurrences of the new user's email
  # in acl keys with the users new id
  # (runs as an after_create callback)
  def update_acls_with_id
    ACLManager.global_replace_user_key( self.email, self.id )

    # set proper acl rights - new users default to regular user rights
    SystemRightsACL.singleton.add_user(self.id, SystemRightsACL::USER_ROLE)
  end

  # returns an array of auto like ids
  # this method is only called by auto_like_ids
  # and gets cached by it
  def self.fetch_auto_like_ids
    likeable_users = [
        'zangzing',
        'phil',
        'mauricio',
        'kathryn',
        'joseph',
        'greg',
        'jeremy'
    ]

    # fetch any ids for the above users
    users = User.select(:id).where(:username => likeable_users)
    auto_like_ids = []
    users.each do |user|
      auto_like_ids << user.id
    end
    auto_like_ids
  end

  def self.auto_like_ids
    @@auto_like_ids ||= fetch_auto_like_ids
  end

  # Make sure everybody likes the zangzing users
  # (runs as an after_create callback)
  def like_mr_zz
    # add all the auto likes
    User.auto_like_ids.each do |auto_like_id|
      if self.id != auto_like_id
        # no liking yourself
        ZZ::Async::ProcessLike.enqueue( 'add', self.id, auto_like_id , 'user' )
      end
    end
  end

end
