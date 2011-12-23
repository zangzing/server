module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class BaseAlbumLoader
      attr_accessor :albums, :json, :compressed, :loader

      def initialize(loader, compressed)
        self.loader = loader
        self.compressed = compressed
      end

      # store the json info only if our type matches track_type
      # the reason we pass compressed here is because it is possible
      # for the compressed data to fail our checks in which case we
      # do not store it but keep in uncompressed
      def store_json(json, compressed, album_type)
        if match_type(album_type)
          self.json = json
          self.compressed = compressed
        end
      end

      # attempt to fetch the item from the cache
      # return nil if not found, otherwise convert
      # back to an object
      def cache_fetch
        ver = current_version
        key = Loader.make_cache_key(self.user.id, self.album_type, ver)
        cache_man.logger.info("Fetching albums cache key: #{key}")
        json = CacheWrapper.read(key)
        z = ZZ::ZZA.new
        if(json.nil?)
          cache_man.logger.info("Cache miss key: #{key}")
          z.track_event("cache.miss.album", key)
        else
          cache_man.logger.info("Cache hit key: #{key}")
          z.track_event("cache.hit.album", key)
          return json
        end

        return nil
      end

      def albums_to_hash(albums)
        loader.albums_to_hash(albums)
      end

      def updated_cache_version
        loader.updated_cache_version
      end

      def current_versions
        loader.current_versions
      end

      def current_version
        current_versions.version(self.album_type)
      end

      # key form of current version, takes schema version into account
      def current_version_key
        "#{::Album.hash_schema_version}.#{current_versions.version(self.album_type)}"
      end

      def etag
        current_versions.etag(self.album_type)
      end

      def current_version=(new_version)
        current_versions.set_version(new_version, self.album_type)
      end

      def public
        loader.public
      end

      def user
        loader.user
      end

      def cache
        loader.cache
      end

      def cache_man
        loader.cache_man
      end

      def tracker
        loader.tracker
      end

      def version_tracker
        loader.version_tracker
      end

      def user_id
        loader.user_id
      end

      def add_tracked_user(user_id, track_type)
        tracker.add([self.user_id, user_id, TrackTypes::USER, track_type])
      end

      # tracks that a user likes other users and cares about like membership changes
      def add_tracked_user_like_membership(user_id, track_type)
        tracker.add([self.user_id, user_id, TrackTypes::USER_LIKE_MEMBERSHIP, track_type])
      end

      def add_tracked_album(album_id, track_type)
        tracker.add([self.user_id, album_id, TrackTypes::ALBUM, track_type])
      end

      # tracks that a user likes other albums and cares about like membership changes
      def add_tracked_album_like_membership(user_id, track_type)
        tracker.add([self.user_id, user_id, TrackTypes::ALBUM_LIKE_MEMBERSHIP, track_type])
      end

      # this tracks changes to the viewer/contrib album acl for a given user
      def add_tracked_user_invites(user_id, track_type)
        tracker.add([self.user_id, user_id, TrackTypes::USER_INVITES, track_type])
      end

      # make sure the latest data is loaded and return the json string
      def fetch_loaded_json()
        load_albums()
        # now update the cache state in the cache db
        # update the cache state and set the json and version for each loader
        loader.update_cache_state(false)

        # and return the albums
        return json
      end

    end
  end
end
