# == Schema Information
# Schema version: 60
#
# Table name: albums
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  privacy         :integer
#  type            :string(255)
#  style           :integer         default(0)
#  open            :boolean
#  event_date      :datetime
#  location        :string(255)
#  stream_share_id :integer
#  reminders       :boolean
#  name            :string(255)
#  suspended       :boolean
#  created_at      :datetime
#  updated_at      :datetime
#

#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  attr_accessible :name
  
  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :dependent => :destroy
  has_many :album_activities, :dependent => :destroy


  validates_presence_of :name, :user_id
  validates_length_of :name, :maximum => 50

  default_scope :order => 'created_at DESC'
end
