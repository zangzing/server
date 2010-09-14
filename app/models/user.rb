# == Schema Information
# Schema version: 60
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  email               :string(255)
#  role                :string(255)
#  username            :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  style               :string(255)     default("white")
#  login_count         :integer
#  last_login_at       :date
#  last_login_ip       :string(255)
#  current_login_at    :date
#  current_login_ip    :string(255)
#  failed_login_count  :integer
#  last_request_at     :date
#  persistence_token   :string(255)
#  single_access_token :string(255)
#  perishable_token    :string(255)     default(""), not null
#  remember_token      :string(255)
#  crypted_password    :string(255)
#  password_salt       :string(255)
#  suspended           :string(255)     default("f")
#  created_at          :datetime
#  updated_at          :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


class User < ActiveRecord::Base
  usesguid
  attr_writer      :name
  attr_accessible  :email, :name, :username, :password

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
 has_many  :follows_users, :through => :follows,  :source => :followed

    
  # This delegates all authentication details to authlogic
  acts_as_authentic do |c|
    c.require_password_confirmation = false
    c.login_field = :email 
  end

  before_save  :split_name

  validates_presence_of :name
  validates_presence_of :username
  validates_presence_of :email
  validates_length_of   :password, :within => 6..40, :if => :require_password?, :message => "must be between 6 and 40 characters long"


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

  # Generates a new perishable token for the notifier to use in a password reset request
  def deliver_password_reset_instructions!
      reset_perishable_token!
      msg = Notifier.create_password_reset_instructions(self)
      Delayed::IoBoundJob.enqueue Delayed::PerformableMethod.new(Notifier, :deliver, [msg] )

  end

  def admin?
     self.role == 'admin'
  end

  def name
    @name ||= (self.first_name ? self.first_name+' ':'')+(self.last_name||'')
  end

  def self.find_by_email_or_username(login)
    find_by_email(login) || find_by_username(login)
  end

  private
    def split_name
      unless name.nil?
        names = name.split
        self.last_name = names.pop
        self.first_name = names.join(' ')
      end
    end

end
