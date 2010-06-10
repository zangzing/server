# == Schema Information
# Schema version: 20100526143648
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  remember_token     :string(255)
#  admin              :boolean
#

# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#


class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible  :name, :email, :password, :password_confirmation, :style
  
  has_many :albums,     :dependent => :destroy
  has_many :identities, :dependent => :destroy
  has_many :shares,     :dependent => :destroy


  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 50
  validates_format_of :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive =>false

  # Automatically create the virtual attribute 'password_confirmation'.
  validates_confirmation_of :password, :if => :perform_password_validation?


  # Password validations.
  validates_presence_of :password, :if => :perform_password_validation?
  validates_length_of   :password, :within => 6..40, :if => :perform_password_validation?

  before_save :encrypt_password, :if => :perform_password_validation?


  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def remember_me!
    self.remember_token = encrypt("#{salt}--#{id}")
    save_without_validation
  end

  def self.authenticate(email, submitted_password)
       user = find_by_email(email)
       return nil  if user.nil?
       return user if user.has_password?(submitted_password)
  end




  def identity_for_gmail
    identity =  self.identities.find(:first, :conditions => "identity_source = 'gmail'")
    if(!identity)
      identity = self.identities.new
      identity.identity_source = "gmail"
    end
    return identity
  end

  def identity_for_facebook
    identity =  self.identities.find(:first, :conditions => "identity_source = 'facebook'")
    if(!identity)
      identity = self.identities.new
      identity.identity_source = "facebook"
    end
    return identity
  end





  def feed
      # This is preliminary. See Chapter 12 for the full implementation.
      Album.all(:conditions => ["user_id = ?", id])
  end 

    private

      def encrypt_password
          self.salt = make_salt
          self.encrypted_password = encrypt(password)
      end

      def encrypt(string)
        secure_hash("#{salt}#{string}")
      end

      def make_salt
        secure_hash("#{Time.now.utc}#{password}")
      end

      def secure_hash(string)
        Digest::SHA2.hexdigest(string)
      end

      def perform_password_validation?
          self.new_record? ? true : !self.password.blank?
      end

end

