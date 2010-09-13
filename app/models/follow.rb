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
  belongs_to :followed, :class_name => "User"
  validates_presence_of :follower_id, :followed_id

  def self.factory(follower, followed)
    existing_f = Follow.find_by_follower_id_and_followed_id( follower.id, followed.id )
    return existing_f if existing_f
    f = follower.follows.build()
    f.followed_id = followed.id
    return f
  end

   def block
    write_attribute(:blocked,  true)
    save
  end

  def unblock
    write_attribute(:blocked,  false)
    save
  end
    
end
