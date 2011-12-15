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
    ( cover ? cover.thumb_url : ProfileAlbum.default_profile_small_url)
  end

  def self.default_profile_small_url
    '/images/profile-default-55.png'
  end

  def self.default_profile_album_url
    '/images/profile-default.png'
  end

  def self.default_profile_album_add_url
    '/images/profile-default-add.png'
  end
end