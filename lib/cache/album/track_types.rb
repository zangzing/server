module Cache
  module Album

    class TrackTypes
      USER                        = 100
      USER_LIKE_MEMBERSHIP        = 101  # tracks a users interest in the membership of the users likes changing
      ALBUM_LIKE_MEMBERSHIP       = 102  # actually tracks a user since cares about membership of albums changing
      ALBUM                       = 103  # tracks an individual album
      USER_INVITES                = 104  # tracks interest in any changes to this users acl for albums
    end

  end
end