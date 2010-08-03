# == Schema Information
# Schema version: 20100707184116
#
# Table name: albums
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

class Album < ActiveRecord::Base
  attr_accessible :name
  
  belongs_to :user
  has_many :photos, :dependent => :destroy
  has_many :shares, :dependent => :destroy



  validates_presence_of :name, :user_id
  validates_length_of :name, :maximum => 50

  default_scope :order => 'created_at DESC'
end
