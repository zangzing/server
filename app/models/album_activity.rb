#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumActivity < Activity
  attr_accessible :album, :photo, :user

  belongs_to :album
  validates_presence_of :album_id
end
