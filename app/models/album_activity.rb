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

class AlbumActivity < Activity
  attr_accessible :album

  belongs_to :album
  validates_presence_of :album_id
end
