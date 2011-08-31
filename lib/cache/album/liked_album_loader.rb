module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class LikedAlbumLoader < BaseAlbumLoader

      def match_type(album_type)
        album_type == AlbumTypes::LIKED_ALBUMS || album_type == AlbumTypes::LIKED_ALBUMS_PUBLIC
      end

      def album_type
        public ? AlbumTypes::LIKED_ALBUMS_PUBLIC : AlbumTypes::LIKED_ALBUMS
      end

      # load or fetch from cache my_albums
      def load_albums
        if (self.json = cache_fetch).nil?
          # not found in the cache, need to call the database to fetch them
          # we need to track all of them regardless of their current state because we
          # have to know of their existence so that when they do change to a visible
          # state we will know.  This means we fetch all and track all but only put
          # the visible ones into the cache
          albums = user.liked_albums

          user_id = user.id
          # now build the list of ones we should put in the cache
          # don't put in ones that haven't been completed or belong to us
          # if someone is fetching our public view, only show public albums
          visible_albums = []
          albums.each do |album|
            next if (album.completed_batch_count == 0) || (user_id == album.user_id)
            visible_albums << album if public == false || (album.privacy == 'public')
          end

          # add all the albums to the tracker even
          # if we can't see it currently so we have
          # a chance to see it change
          # don't track our own albums that we like
          # since they should not show up
          albums.each do |album|
            add_tracked_album(album.id, album_type) unless album.user_id == user_id
          end
          # and add a user_id tracker for ourselves so we know if we like or unlike an album
          add_tracked_album_like_membership(user_id, album_type)

          # and update the cache with the albums
          self.current_version = updated_cache_version if current_version == 0
          self.albums = albums_to_hash(visible_albums)
          version_tracker.add([album_type, self.albums, current_version])
        end
      end

    end
  end
end
