# == Schema Information
# Schema version: 60
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  email               :string(255)
#  role                :string(255)
#  user_name           :string(255)
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
#   √î√∏Œ© 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


class User < ActiveRecord::Base
  usesguid
  attr_writer      :name
  attr_accessible  :email, :name, :password, :password_confirmation, :style

  has_many :albums,              :dependent => :destroy
  has_many :identities,          :dependent => :destroy
  has_many :shares
  has_many :followers,           :dependent => :destroy
  has_many :activities,          :dependent => :destroy
  has_many :photos
  has_many :upload_batches
  has_many :client_applications, :dependent => :destroy 
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]

  has_many :followees, :through => :follows, :class_name => 'User', :dependent => :destroy
  has_many :followers, :through => :follows, :class_name => 'User'
    

  acts_as_authentic         # This delegates all authentication details to authlogic

  before_save  :split_name



  validates_presence_of :name
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
      Emailer.deliver_password_reset_instructions(self)
  end

  def admin?
     self.role == 'admin'
  end

  def name
    @name ||= (self.first_name ? self.first_name+' ':'')+(self.last_name||'')
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
