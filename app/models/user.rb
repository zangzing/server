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
  attr_accessible  :name, :email, :password, :password_confirmation, :style
  
  has_many :albums,     :dependent => :destroy
  has_many :identities, :dependent => :destroy
  has_many :shares,     :dependent => :destroy


  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 50
  validates_format_of :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive =>false


  acts_as_authentic


  def identity_for_gmail
    identity =  self.identities.find(:first, :conditions => "identity_source = 'gmail'")
    if(!identity)
      identity = self.identities.new
      identity.identity_source = "gmail"
    end
    return identity
  end

  def feed
      # This is preliminary. See Chapter 12 for the full implementation.
      Album.all(:conditions => ["user_id = ?", id])
  end

  def deliver_password_reset_instructions!
      reset_perishable_token!
      Mailer.deliver_password_reset_instructions(self)
  end

end

