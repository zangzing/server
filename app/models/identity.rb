# == Schema Information
# Schema version: 60
#
# Table name: identities
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  type                 :string(255)
#  name                 :string(255)
#  credentials          :string(255)
#  last_contact_refresh :datetime
#  identity_source      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Identity < ActiveRecord::Base

  belongs_to :user
  has_many :contacts, :dependent => :destroy

  validates_presence_of :user_id
  
  def self.new_for_gmail
    identity = self.new
    identity.identity_source="gmail"
  end

end
