module Cache
  module Album

    class TrackTypes
      MY_ALBUMS                   = 1
      MY_ALBUMS_PUBLIC            = 2
      LIKED_ALBUMS                = 3
      LIKED_ALBUMS_PUBLIC         = 4
      LIKED_USERS_ALBUMS_PUBLIC   = 5   # this one is always public

      USER                        = 10
      USER_LIKE_MEMBERSHIP        = 11  # tracks a users interest in the membership of the users likes changing
      ALBUM_LIKE_MEMBERSHIP       = 12  # actually tracks a user since cares about membership of albums changing
      ALBUM                       = 20
    end

  end
end