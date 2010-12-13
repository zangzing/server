#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

# "automatic" users are created when a contributor adds photos by email but does not have
# an accoung

class User < ActiveRecord::Base
  usesguid
  attr_writer      :name
  attr_accessor    :old_password, :reset_password
  attr_accessible  :email, :name, :first_name, :last_name, :username,  :password, :old_password, :automatic

  has_many :albums,              :dependent => :destroy
  has_many :identities,          :dependent => :destroy
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
  end

  before_save  :split_name

  validates_presence_of :name, :unless => :automatic?
  validates_presence_of :username, :unless => :automatic?
  validates_format_of :username, :with => /^[a-z0-9]+$/, :on => :create, :message => 'Should contaion only lowercase alphanumeric characters'
  validates_uniqueness_of :username, :message => "Has already been taken", :unless => :automatic?
  validates_presence_of :email
  validates_length_of  :password, :within => 6..40, :if => :require_password?, :message => "must be between 6 and 40 characters long"
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



  def self.find_by_email_or_create_automatic( email, name='' )
    user = User.find_by_email( email );
    if user.nil?
      mail_name = username = email.split('@').first
      i = 1
      begin
        username = "#{mail_name}#{i}"
        i += 1
      end while User.find_by_username(username)
      #user not fount create an automatic user with a random password
      user = User.create!(  :automatic => true,
                           :email => email,
                           :name => name,
                           :username => username,  #username is in DB index, so '' won't work
                           :password => UUID.random_create.to_s);
    end
    return user
  end

  def has_identity?( service_name )
    self.identities.find(:first, :conditions => {:identity_source => service_name.to_s})
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
     self.role == 'admin'
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

  def avatar_url
    return gravatar_url_for( self.email )
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

  def gravatar_url_for(email)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
  end

end
