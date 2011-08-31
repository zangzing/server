module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class LikedUserAlbumLoader < BaseAlbumLoader
      LIKED_USERS_ALBUMS_PUBLIC   = 31   # this one is always public

      def match_type(album_type)
        album_type == AlbumTypes::LIKED_USERS_ALBUMS_PUBLIC
      end

      def album_type
        AlbumTypes::LIKED_USERS_ALBUMS_PUBLIC
      end

      # load or fetch from cache my_albums
      def load_albums
        if (self.json = cache_fetch).nil?
          # not found in the cache, need to call the database to fetch them
          albums = user.liked_users_public_albums
          # now build the list of ones we should put in the cache
          # don't put in ones that belong to us
          user_id = user.id
          visible_albums = []
          albums.each do |album|
            next if user_id == album.user_id
            visible_albums << album if public == false || (album.privacy == 'public')
          end

          # add the users we like to the tracker set
          # because it is a set, duplicates will be filtered
          # user_id, tracked_id, album_type
          albums.each do |album|
            add_tracked_user(album.user_id, album_type)
          end
          # and add a user_id tracker for ourselves so we know if we like or unlike a user
          add_tracked_user_like_membership(user_id, album_type)

          # and update the cache with the albums
          self.current_version = updated_cache_version if current_version == 0
          self.albums = albums_to_hash(visible_albums)
          version_tracker.add([album_type, self.albums, current_version])
        end
      end

    end
  end
end
