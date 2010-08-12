# == Schema Information
# Schema version: 60
#
# Table name: followers
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  leader_id   :integer
#  blocked     :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Follow < ActiveRecord::Base
  belongs_to :follower, :class_name => "User"
  belongs_to :followee, :class_name => "User"
  validates_presence_of :follower_id, :followee_id
end
