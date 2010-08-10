# == Schema Information
# Schema version: 60
#
# Table name: contacts
#
#  id          :integer         not null, primary key
#  identity_id :integer
#  type        :string(255)
#  name        :string(255)
#  address     :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Contact < ActiveRecord::Base
  belongs_to :identity
  validates_presence_of :identity
end
