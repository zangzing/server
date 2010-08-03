# == Schema Information
# Schema version: 20100707184116
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  email               :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  remember_token      :string(255)
#  admin               :boolean
#  style               :string(255)     default("white")
#  crypted_password    :string(255)
#  password_salt       :string(255)
#  persistence_token   :string(255)
#  single_access_token :string(255)
#  perishable_token    :string(255)     default(""), not null
#  login_count         :integer
#  failed_login_count  :integer
#  last_request_at     :date
#  current_login_at    :date
#  last_login_at       :date
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#


class User < ActiveRecord::Base
  attr_accessible  :name, :email, :password, :password_confirmation, :style
  
  has_many :albums,       :dependent => :destroy
  has_many :identities,   :dependent => :destroy
  has_many :shares,       :dependent => :destroy
  has_many :client_applications, :dependent => :destroy 
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]
  

  # This delegates all authentication details to authlogic
  acts_as_authentic

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

  # Generates a new perishable token for the mailer to use in a password reset request
  def deliver_password_reset_instructions!
      reset_perishable_token!
      Mailer.deliver_password_reset_instructions(self)
  end
end
