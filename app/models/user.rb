#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

# "automatic" users are created when a contributor adds photos by email but does not have
# an account
require 'mail'
require 'zzapi_error'

class User < ActiveRecord::Base
  attr_accessor    :old_password, :reset_password, :change_matters
  attr_accessible  :email, :name, :first_name, :last_name, :username,  :password, :password_confirmation,
                   :old_password, :automatic, :profile_photo_id, :subscriptions_attributes,
                   :ship_address_id, :bill_address_id, :creditcard_id, :auto_by_contact, :created_by_user_id

  has_many :albums      # we have a manual dependency to delete albums on destroy since nested rails callbacks don't seem to be triggered

  #things I like, join with likes table
  has_many :likes
  has_many :liked_albums,         :through => :likes, :class_name => "Album", :source => :subject,  :conditions => "likes.subject_type = 'A'"
  has_many :liked_users,          :through => :likes, :class_name => "User",  :source => :subject,  :conditions => { 'likes.subject_type' => 'U'}
  has_many :liked_photos,         :through => :likes, :class_name => "Photo", :source => :subject,  :conditions => { 'likes.subject_type' => 'P'}

  # pull in all public albums for the users this user likes
  has_many :liked_users_public_albums,   :class_name => "Album", :finder_sql =>
      'SELECT a.* ' +
      'FROM albums a, likes l, users u ' +
      'WHERE l.user_id = #{id} AND l.subject_id = u.id AND u.id = a.user_id ' +
      'AND l.subject_type = "U" AND a.privacy = "public" AND a.completed_batch_count > 0 AND a.type <> "ProfileAlbum" ' +
      'ORDER BY a.updated_at DESC'


  has_many :liked_users_activities,   :class_name => "Activity", :finder_sql =>
      'SELECT a.* ' +
      'FROM activities a, likes l, users u ' +
      'WHERE l.user_id = #{id} AND l.subject_id = u.id AND u.id = a.user_id ' +
      'AND l.subject_type = "U"'+
      'ORDER BY a.updated_at DESC'


  #Reverse lookup join likers ar those who like me
  has_many :follow_mees,         :foreign_key => :subject_id, :class_name => "Like", :conditions => { 'likes.subject_type' => 'U'}
  has_many :followers,           :through => :follow_mees, :class_name => "User",  :source => :user

  has_one  :profile_album,       :dependent => :destroy, :autosave => true
  has_one  :preferences,         :dependent => :destroy, :class_name => "UserPreferences", :autosave => true
  has_one  :subscriptions,       :autosave => true
  accepts_nested_attributes_for  :subscriptions

  has_many :identities,          :dependent => :destroy
  has_many :contacts,            :through => :identities, :class_name => "Contact"
  has_many :groups

  has_many :shares
  has_many :activities,          :dependent => :destroy
  has_many :photos
  has_many :upload_batches
  has_many :client_applications, :dependent => :destroy 
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]

  #invitations
  has_many :sent_invitations, :class_name => "Invitation", :foreign_key => "user_id"
  has_many :received_invitations, :class_name => "Invitation", :foreign_key => "invited_user_id"




  #SPREE
  has_many   :addresses
  has_many   :creditcards
  has_many   :orders
  belongs_to :ship_address, :foreign_key => "ship_address_id", :class_name => "Address"
  belongs_to :bill_address, :foreign_key => "bill_address_id", :class_name => "Address"
  belongs_to :creditcard

  # This delegates all authentication details to authlogic
  acts_as_authentic do |c|
    c.validates_confirmation_of_password_field_options = {:if => :require_password?, :on => :update }
    c.validates_length_of_password_confirmation_field_options = {:minimum => 0, :if => :require_password?, :on => :update}
    c.login_field = :email
    c.validate_login_field = false
    c.disable_perishable_token_maintenance=true
  end

  before_save    :split_name
  before_create  :set_dependents
  after_commit   :add_system_rights, :on => :create
  after_commit   :like_mr_zz_if_full_user, :on => :create
  after_commit   :subscribe_to_lists, :on => :create

  after_save    :check_cache_manager_change
  after_commit  :notify_cache_manager

  after_create   :make_wrapped_group

  before_validation :username_to_downcase
  validates_presence_of   :name,      :unless => :automatic?
  validates_presence_of   :username,  :unless => :automatic?
  validates_format_of     :username,  :with => /^[a-z0-9]+$/, :message => 'should contain only lowercase alphanumeric characters', :unless => :automatic?
  validates_uniqueness_of :username,  :message => "has already been taken", :unless => :automatic?
  validates_presence_of   :email
  validates_length_of     :password, :within => 6..40, :if => :require_password?, :message => "must be between 6 and 40 characters long"
  validate :old_password_valid?, :on => :update, :unless => :reset_password


  has_friendly_id :username

  BONUS_STORAGE_MB_PER_INVITE = 0.25 * 1024
  MAX_BONUS_MB = 8 * 1024

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

  # taking over the dependent delete since rails does not seem to call the :on => :destroy callbacks
  # for the second level and beyond dependencies.  In other words, if a dependent delete causes
  # an album to be deleted, the :on => :destroy condition for the photos under it does not seem to trigger.
  #
  # Later on we should make the dependent deletes more efficient by not having them instantiate objects
  # when possible.  In most cases it will be sufficient to simply have the object ids passed down
  # in bulk.
  #
  def destroy
    DeferredCompletionManager.dispatch do
      # unsubscribe all emails
      (MailingList.user_cleanup(self) rescue nil) unless automatic?

      # destroy in bulk any groups and group members related to this id and perform acl notifications
      # for all of them, also removes all groups from the acls
      User.remove_all_groups_for_user(id)

      # destroy the albums
      # someday we should do this in bulk
      albums = self.albums
      if !albums.nil?
        albums.each do |album|
          album.destroy
        end
      end
      super
    end
  end

  # given a user_id, remove all groups owned by that
  # user for all resources and types, also bulk deletes
  # the groups and notifies the cache manager for each user
  # affected
  def self.remove_all_groups_for_user(user_id)
    # get group ids owned by this user
    group_ids = Group.groups_for_user(user_id)

    Group.delete_groups_and_acls(group_ids)
  end

  # check to see if the change matters - we do this
  # before the commit because once it is committed we
  # no longer know what changed
  #
  def check_cache_manager_change
    self.change_matters = username_changed?
    true
  end

  # We have been committed so call the album cache manager
  # to let it invalidate caches if needed.  We do this separately from
  # the change check because we must do this after the commit to
  # make sure we are not in a transaction
  def notify_cache_manager
    if destroyed? == false && change_matters
      Cache::Album::Manager.shared.user_invalidate_cache(id)
    end
    true
  end

  # cohort related calculations

  # this represents the beginning date of cohort 1
  def self.cohort_base
    @@cohort_base ||= DateTime.civil(2011,4)
  end

  # calculate the cohort number from the given date
  def self.cohort_from_date(curr)
    # move forward 1 month to include all of the current month
    curr = curr.in_time_zone("GMT")
    forward = curr >> 1
    f_y = forward.year
    f_m = forward.month
    b_y = cohort_base.year
    b_m = cohort_base.month

    # calculate the cohort number, < 1 is cohort 1
    cohort = (f_y - b_y) * 12 + (f_m - b_m)
    return cohort < 1 ? 1 : cohort
  end

  # return the cohort based on the current date
  def self.cohort_current
    return cohort_from_date(DateTime.now())
  end


  def set_dependents
    # build a profile album only when not auto_by_contact?
    if auto_by_contact? == false
      p = ProfileAlbum.new()
      p.make_private
      self.profile_album = p
    end

    # build user preferences
    self.build_preferences

    # set the cohort we belong to
    self.cohort = User.cohort_current

    #build subscriptions, initially all are on so turn off news and marketing which are mail chimp lists
    self.subscriptions = Subscriptions.find_or_initialize_by_email( self.email )
    self.subscriptions.unsubscribe(Email::NEWS) if automatic?
    self.subscriptions.unsubscribe(Email::MARKETING) if automatic?
  end

  # convert an automatic user to a full user
  def convert_to_full_user(name, username, password)
    return unless automatic?

    # The user is an automatic user because she had contributed photos after being invited by email
    # she has now decided to join, remove automatic flag and reset password.
    if auto_by_contact?
      self.cohort = User.cohort_current # if they are auto due to simply being created because someone referenced that email address then the real cohort is now
      self.auto_by_contact = false       # a full user now
    end
    self.automatic = false
    self.name      = name
    self.username  = username
    self.reset_password = true
    self.password  = password
    self.password_confirmation = password

    # add in the profile album now
    create_profile_album if profile_album.nil?

    # now add back mail chimp only since we keep all internal subscription types on initially
    self.subscriptions.update_subscription(Email::MARKETING, Subscriptions::IMMEDIATELY)
    self.subscriptions.update_subscription(Email::NEWS, Subscriptions::IMMEDIATELY)

    # and like mr zz
    like_mr_zz
  end

  def subscribe_to_lists
    # don't subscribe to mail chimp lists when automatic user
    MailingList.subscribe_new_user(id) unless automatic?
  end

  def self.create_automatic(email, name = '', auto_by_contact = false, created_by_user = nil)
    name = ( name.blank? ? '' : name )
    created_by_user_id = created_by_user.nil? ? nil : created_by_user.id
    # create an automatic user with a random password
    user = User.new(  :automatic => true,
                         :email => email,
                         :name => name,
                         :created_by_user_id => created_by_user_id,
                         :auto_by_contact => auto_by_contact,
                         :username => UUIDTools::UUID.random_create.to_s.gsub('-','').to_s,
                         :password => UUIDTools::UUID.random_create.to_s)
    user.reset_perishable_token
    user.save_without_session_maintenance
    if user.id.nil?
      # unable to create
      joined_msg = user.errors.full_messages.join(", ")
      msg = "Unable to create automatic user for name: #{name}, email: #{email} due to #{joined_msg}"
      logger.error(msg)
      raise ActiveRecord::RecordInvalid.new(user)
    end
    user
  end

  def self.find_by_email_or_create_automatic( email, name='', auto_by_contact = false)
    user = User.find_by_email( email )
    if user
      if user.automatic? && user.auto_by_contact? && auto_by_contact == false
        # no longer an auto by contact user
        user.auto_by_contact = false
        user.cohort = User.cohort_current # we now have a cohort
        user.save # not crucial if this fails so ignore any error
      end
    else
      begin
        #user not found, create an automatic user with a random password
        user = create_automatic(email, name, auto_by_contact)
      rescue ActiveRecord::RecordInvalid => ex
        user = nil
      end
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
      ZZ::Async::Email.enqueue_high( :password_reset, self.id )
  end

  def deliver_activation_instructions!
      reset_perishable_token!
      ZZ::Async::Email.enqueue_high( :activation_instructions, self.id )
  end

  def deliver_welcome!
     ZZ::Async::Email.enqueue( :welcome, self.id )
  end

  def admin?
    @is_admin ||= SystemRightsACL.singleton.has_permission?(self.id, SystemRightsACL::ADMIN_ROLE)
  end

  def support_hero?
    @is_support_hero ||= SystemRightsACL.singleton.has_permission?(self.id, SystemRightsACL::SUPPORT_HERO_ROLE)
  end

  def moderator?
    @is_moderator ||= SystemRightsACL.singleton.has_permission?(self.id, SystemRightsACL::MODERATOR_ROLE)
  end

  def super_moderator?
    @is_super_moderator ||= SystemRightsACL.singleton.has_permission?(self.id, SystemRightsACL::SUPER_MODERATOR_ROLE)
  end

  def email=(email)
    write_attribute( :email, email)
    if email_changed?
      self.subscriptions.email=email unless self.subscriptions.nil?
    end
  end

  # override behavior of name to optionally not
  # show the anonymous user name when blank for automatic users
  def name(show_anonymous = true)
    if show_anonymous && automatic? && first_name.blank? && last_name.blank?
      'Anonymous'
    else
      @name ||= [first_name, last_name].compact.join(' ').strip
    end
  end

  def name=(val)
    @name = val
    split_name    # and update first, last
  end

  def first_name=(name)
    super(name)
    @name = nil   # invalidate full name
  end

  def last_name=(name)
    super(name)
    @name = nil   # invalidate full name
  end

  #returns whichever has a value: first name, last name, username
  def short_name
    if self.first_name && self.first_name.strip.length > 0
      return self.first_name
    elsif self.last_name && self.last_name.strip.length > 0
      return self.last_name
    else
      return self.username
    end
  end

  def posessive_short_name
    @posessive_shortname ||= self.short_name + ('s' == self.short_name[-1,1] ? "'" : "'s")
  end


  def posessive_name
    @posessive_name ||= self.name + ('s' == self.name[-1,1] ? "'" : "'s")
  end

  def posessive_first_name
    @posessive_first_name ||= self.first_name + ('s' == self.first_name[-1,1] ? "'" : "'s")
  end


  def activate!
      self.active = true
      save
  end

  def deactivate!
    self.active = false
    save
  end

  def self.find_by_email_or_username(login)
    # both are case insensitive
    if login.index('@')
      find_by_email(login)
    else
      find_by_username(login)
    end
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

  def profile_photo_url(default_on_nil = true)
      create_profile_album if profile_album.nil?
      @profile_photo_url ||= profile_album.profile_photo_url(default_on_nil)
  end

  def formatted_email
      "#{self.name} <#{self.email}>"
  end

  # used when someone wants to sort on name
  # determines proper name to use based on type
  def name_sort_value
    real_name = name(false)   # no anonymous conversion
    if automatic? && real_name.blank?
      val = email
    else
      val = real_name
    end
    val
  end


  # return the list of users as an array
  def self.as_array(members, user_id_to_email)
    result = []
    members.each do |member|
      result << member.basic_user_info_hash(user_id_to_email)
    end
    result
  end

  # return a has of basic user info used by the api
  # user_id_to_email is has of user_id => email that
  # if present will be used to supplement the email
  # address which is normally not returned
  def basic_user_info_hash(user_id_to_email = nil)
    # fetch profile photo, if automatic won't have one so don't waste overhead trying to fetch
    profile_photo = automatic? ? nil : profile_photo_url(false)   # do not want default url if nil, want nil in that case
    user_info = {
      :id => id,
      :my_group_id => my_group_id,
      :username => username,
      :profile_photo_url => profile_photo,
      :first_name => first_name,
      :last_name => last_name,
      :automatic => automatic?,
      :auto_by_contact => auto_by_contact?,
      :created_by_user_id => created_by_user_id,
    }
    # see if email should be included in returned data
    add_email = automatic? ? email : nil
    # see if our id is included, if so add/override email to give user matching context
    if user_id_to_email
      add_email = user_id_to_email[id] || add_email
    end
    user_info[:email] = add_email if add_email
    user_info
  end

  # Generate a friendly string randomly to be used as token.
  def self.friendly_token
    ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
  end

  # Generate a token by looping and ensuring does not already exist.
  def self.generate_token(column)
    loop do
      token = friendly_token
      break token unless find(:first, :conditions => { column => token })
    end
  end
  
  # validates user ids
  # takes an array of user ids, if any are invalid, they will be returned in error list
  #
  # returns array of user_ids, errors
  # errors list is in the standard format defined by ZZAPIInvalidListError
  #
  def self.validate_user_ids(ids)
    errors = []
    user_ids = []
    if ids && ids.length > 0
      users = User.select("id").where(:id => ids)
      user_ids = users.map(&:id)
      found_ids = Set.new(user_ids)
      errors = ZZAPIInvalidListError.build_missing_list(ids, found_ids)
    end
    [user_ids, errors]
  end

  # validates user names
  # takes an array of user names, if any are invalid, they will be returned in error list
  #
  # returns array of user_ids, errors
  # errors list is in the standard format defined by ZZAPIInvalidListError
  #
  def self.validate_user_names(names)
    errors = []
    user_ids = []
    if names && names.length > 0
      users = User.select("id, username").where(:username => names)
      found_names = {}
      users.each do |user|
        user_id = user.id
        user_ids << user_id
        found_names[user.username] = user_id
      end
      errors = ZZAPIInvalidListError.build_missing_list(names, found_names)
    end
    [user_ids, errors]
  end

  # For each member in the array, try to find an existing email to user id mapping.
  # For those not found when the create flag is true we create new automatic users.
  #
  # returns array of users, and a hash of user_id => email, the mapping to email
  # is used when we return the info about a user to the caller because if they pass
  # in the email we want to give it back to them so they can associate the returned
  # user with the email they passed
  #
  # users, user_id_to_email
  #
  # NOTE: the users returned only contain id, email, my_group_id
  def self.convert_to_users(addresses, created_by_user, create)
    users = []
    # make a copy of only the unique entries
    addresses = addresses.uniq

    if addresses.empty? == false
      # first find the ones that map to a user
      emails = addresses.map(&:address)
      users = User.select("id,email,my_group_id").where(:email => emails)

      if create
        # create a map from email to user_id
        email_to_user = {}
        users.each {|user| email_to_user[user.email.downcase] = user }
        #todo, for missing users, check secondary email table here once we have it

        # ok, now walk the members to find out which ones need a new user created
        addresses.each do |address|
          email = address.address
          user = email_to_user[email.downcase]
          if user.nil?
            # not found, so make an automatic user
            name = address.display_name
            if name.blank?
              # when blank, and they have a matching contact, use the name from it
              contact = created_by_user.contacts.find_by_address(email)
              name = contact.formatted_email if contact
            end
            user = User.create_automatic(email, name, true, created_by_user)
            users << user
          end
        end
      end
    end

    # build user_id to email hash
    user_id_to_email = {}
    users.each {|user| user_id_to_email[user.id] = user.email }

    return users, user_id_to_email
  end


  def account_plan
    if @account_plan.nil?
      @account_plan = AccountPlan.new(storage_used, usable_bonus_storage)
    end

    return @account_plan

  end



  def usable_bonus_storage
    [MAX_BONUS_MB, bonus_storage].min
  end


  def storage_used
    if @storage_used.nil?

      # slow, easy to read sql
      #
      # sql = "select sum(photos.image_file_size) from ( " +
      #          "select photos.* from photos, albums where photos.album_id = albums.id and albums.user_id = #{id} " +
      #          "union " +
      #          "select photos.* from photos where photos.user_id = #{id} " +
      #       ") as photos"


      # fast, hard to read equivalent
      #
      # sql = "select COALESCE(my_photos_size,0) + COALESCE(other_photos_size,0) as total_size from " +
      #       "(select sum(image_file_size) as my_photos_size from photos where user_id = #{id}) as p1, " +
      #       "(select sum(photos.image_file_size) as other_photos_size from photos, albums where photos.album_id = albums.id AND albums.user_id = #{id} AND photos.user_id <> #{id}) as p2"

      # ok, now change to just charge album owner for storage
      #
      sql = "select sum(photos.image_file_size) from photos, albums where photos.album_id = albums.id and albums.user_id = #{id}"

      row = User.connection.execute(sql).first

      if row[0].nil?
        @storage_used = 0
      else
        used = row[0].to_int / 1024 / 1024
        @storage_used = (used * 1.2).to_int # add 20% to account for derived images
      end

    end

    return @storage_used
  end





  private
  def old_password_valid?
    if (require_password? || (old_password && old_password.length > 0) ) && !new_record? && !valid_password?(old_password)
      errors.add(:old_password, "Your old password does not match our records")
      false
    else
      true
    end
  end


  def require_password?
    # only require password if password field changed in an update or if resseting your password
    password_changed? || (crypted_password.blank? && !new_record?) || reset_password 
  end

  # split name into first and last, if more than 2 parts
  # the extra goes with first, last gets only the last one
  # if nil or empty gives empty strings for first,last
  def split_name
    first = ''
    last = ''
    long_name = name(false) # name without anonymous
    if
      names = long_name.split
      len = names.length
      if len > 1
        last = names.pop
        first = names.join(' ')
      elsif len == 1
        first = names.pop
        last = ''
      end
    end
    self.first_name = first
    self.last_name = last
  end

  def username_to_downcase
    self.username.downcase!
  end
 
  # after creating, make the wrapped group for this user
  # also updates the my_group_id field of this user directly because
  # we don't want to trigger another save since we are in a callback now
  def make_wrapped_group
    group = Group.create_wrapped_user(self.id)
    group_id = group.id
    # direct write the my_group_id
    base_cmd = "INSERT INTO #{User.quoted_table_name}(id, my_group_id) VALUES "
    end_cmd = "ON DUPLICATE KEY UPDATE my_group_id = VALUES(my_group_id)"
    rows = [[self.id, group_id]]
    RawDB.fast_insert(User.connection, rows, base_cmd, end_cmd)
    self.my_group_id = group_id
  end

  # Replaces any occurrences of the new user's email
  # in acl keys with the users new id
  # (runs as an after_create callback)
  def add_system_rights
    # new user, so set system rights to default
    SystemRightsACL.singleton.add_user(self, SystemRightsACL::USER_ROLE)
  end



  # returns an array of auto like ids
  # this method is only called by auto_like_ids
  # and gets cached by it
  def self.fetch_auto_like_ids
    likeable_users = [ 'zangzing' ]

    # fetch any ids for the above users
    users = User.select(:id).where(:username => likeable_users)
    auto_like_ids = []
    users.each do |user|
      auto_like_ids << user.id
    end
    auto_like_ids
  end

  def self.auto_liking=(value)
    @@auto_liking = value
  end

  def self.auto_liking?
    @@auto_liking = true unless defined?(@@auto_liking)
    @@auto_liking
  end

  def self.auto_like_ids
    auto_liking? ? @@auto_like_ids ||= fetch_auto_like_ids : []
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

  def like_mr_zz_if_full_user
    like_mr_zz unless automatic?
  end

  # handy utility method to delete an array of ids all at once
  def self.delete_list_of_user_ids(user_ids)
    user_ids.each do |user_id|
      u = User.find_by_id(user_id)
      if !u.nil?
        puts u.id
        u.destroy
      end
    end
  end


end
