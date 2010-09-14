# == Schema Information
# Schema version: 60
#
# Table name: activities
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  user_id    :integer
#  album_id   :integer
#  payload    :text
#  created_at :datetime
#  updated_at :datetime
#

#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Activity < ActiveRecord::Base
  attr_accessible :user

  belongs_to :user
  validates_presence_of :user_id
end