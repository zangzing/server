module Cache
  module Album

    class AlbumTypes
      MY_ALBUMS                   = 11
      MY_ALBUMS_PUBLIC            = 12
      LIKED_ALBUMS                = 21
      LIKED_ALBUMS_PUBLIC         = 22
      LIKED_USERS_ALBUMS_PUBLIC   = 32   # this one is always public
      MY_INVITED_ALBUMS           = 41   # the albums I am a viewer or contributor for via the ACL for the albums
      MY_INVITED_ALBUMS_PUBLIC    = 42   # the albums I am a viewer or contributor for via the ACL for the albums
      ACTIVITY                    = 43
      ACTIVITY_PUBLIC             = 44
    end

  end
end