#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


class ProfileAlbum < Album

  #name cannot be changed
  def name=( new_name )
  end

  def name
    "Profile Photos"
  end

  def profile_photo_id=( id )
    self.cover_photo_id = id
  end

  def profile_photo_id
    ( cover ?  cover.id : nil )
  end

  def profile_photo_url
    ( cover ? cover.thumb_url : ProfileAlbum.default_profile_url)
  end

  def self.default_profile_url
    '/images/default_profile.png'
  end

  def self.default_profile_cover_url
    '/images/default_profile_add.png'
  end

end