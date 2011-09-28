module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class InvitedAlbumLoader < BaseAlbumLoader

      def match_type(album_type)
        album_type == AlbumTypes::MY_INVITED_ALBUMS || album_type == AlbumTypes::MY_INVITED_ALBUMS_PUBLIC
      end

      def album_type
        public ? AlbumTypes::MY_INVITED_ALBUMS_PUBLIC : AlbumTypes::MY_INVITED_ALBUMS
      end

      # load or fetch from cache my_albums
      def load_albums
        if (self.json = cache_fetch).nil?
          # not found in the cache, need to call the database to fetch them
          user_id = user.id
          if (public)
            albums = []
          else
            # get all the acls for this user so we can find albums in one query
            # also need to track album_id => role so after we have the album we
            # can attach that local data to each album result
            album_ids = []
            album_roles = {}
            tuples = AlbumACL.get_acls_for_user(user_id, AlbumACL::VIEWER_ROLE, false)
            tuples.each do |tuple|
              album_id = tuple.acl_id.to_i
              album_ids << album_id
              album_roles[album_id] = tuple.role.name
            end
            # now do the query to fetch all the albums
            albums = ::Album.find(:all, :conditions => ['id IN (?)', album_ids])
          end

          # add ourselves to the track set because we want to be
          # invalidated if our albums change
          # user_id, tracked_id, album_type
          user_id = user.id
          # now build the list of ones we should put in the cache
          # don't put in ones that are ours - should we also not show albums we are a viewer for unless it has batch > 0?
          visible_albums = []
          albums.each do |album|
            next if (user_id == album.user_id)  # don't show our own albums
            album_id = album.id
            album.my_role = album_roles[album_id]
            # track the ones we care about if they change
            add_tracked_album(album_id, album_type)
            visible_albums << album
          end

          # track any additions or removals from our acl
          add_tracked_user_invites(user_id, album_type)

          # and update the cache with the albums
          self.current_version = updated_cache_version if current_version == 0
          self.albums = albums_to_hash(visible_albums)
          version_tracker.add([album_type, self.albums, current_version])
        end
      end

    end
  end
end
