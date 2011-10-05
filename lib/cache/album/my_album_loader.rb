module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class MyAlbumLoader < BaseAlbumLoader

      def match_type(album_type)
        album_type == AlbumTypes::MY_ALBUMS || album_type == AlbumTypes::MY_ALBUMS_PUBLIC
      end

      def album_type
        public ? AlbumTypes::MY_ALBUMS_PUBLIC : AlbumTypes::MY_ALBUMS
      end

      # load or fetch from cache my_albums
      def load_albums
        if (self.json = cache_fetch).nil?
          # not found in the cache, need to call the database to fetch them
          if (public)
            albums = user.albums.where("privacy = 'public' AND completed_batch_count > 0")
          else
            albums = user.albums
          end

          # add ourselves to the track set because we want to be
          # invalidated if our albums change
          # user_id, tracked_id, track_type
          user_id = user.id
          add_tracked_user(user_id, album_type)

          # and update the cache with the albums
          self.current_version = updated_cache_version if current_version == 0
          self.albums = albums_to_hash(albums)
          version_tracker.add([album_type, self.albums, current_version])
        end
      end

    end
  end
end
