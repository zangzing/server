module Cache
  module Album

    # This class handles the loading of the cache from albums and storing/fetching from
    # the cache.  It also tracks cache versions and sets up the tracked dependencies.
    class Loader
      attr_accessor :user, :user_id, :cache_man, :public, :current_versions, :user_id_to_name_map,
                    :tracker, :version_tracker, :user_last_touch_at,
                    :my_albums, :my_albums_json,
                    :liked_albums, :liked_albums_json,
                    :liked_users_albums, :liked_users_albums_json


      def initialize(cache_man, user, public)
        self.user = user
        self.user_id = user.id
        self.cache_man = cache_man
        self.public = public

        # see what the current versions are
        self.current_versions = load_current_versions()

        # optimize fetching of user names by collecting them here
        self.user_id_to_name_map = {}

        # this tracks the items that need to be updated in the database for
        # our current dependencies
        self.tracker = Set.new()

        # tracks which caches and versions need updating so we can
        # do a single db update
        self.version_tracker = Set.new()

        # grab a consistent time to mark the last touch and
        # any cache version changes
        self.user_last_touch_at = Time.now().to_i
      end

      def cache
        Rails.cache
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

      # get a new version, we use time in seconds
      # which should be ok.  Technically we could have
      # a collision if someone else was changing this user
      # at the same time but in most scenarios they would
      # end up with the same data anyways.
      def updated_cache_version
        return self.user_last_touch_at
      end

      def self.make_cache_key(user_id, track_type, ver)
        Manager::KEY_PREFIX + "#{track_type}.#{user_id}.#{ver}"
      end

      # attempt to fetch the item from the cache
      # return nil if not found, otherwise convert
      # back to an object
      def cache_fetch(track_type, ver)
        key = Loader.make_cache_key(self.user.id, track_type, ver)
        cache_man.logger.info("Fetching albums cache key: #{key}")
        json = cache.read(key)
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

      # updates the caches and does a single
      # database operation to update any changed cache versions
      def update_caches
        ver_values = []
        user_id = self.user.id
        version_tracker.each do |item|
          track_type = item[0]
          albums = item[1]
          ver = item[2]
          key = Loader.make_cache_key(user_id, track_type, ver)

          json = JSON.fast_generate(albums)

          # compress the content once before caching: save memory and save nginx from compressing every response
          json = ActiveSupport::Gzip.compress(json)

          cache_man.logger.info "Caching #{key}"
          cache.write(key, json, :expires_in => Manager::CACHE_MAX_INACTIVITY)

          ver_values << [user_id, track_type, ver, user_last_touch_at]

          # now store the json for this cache for later retrieval
          case track_type
            when TrackTypes::MY_ALBUMS, TrackTypes::MY_ALBUMS_PUBLIC
              self.my_albums_json = json
            when TrackTypes::LIKED_ALBUMS, TrackTypes::LIKED_ALBUMS_PUBLIC
              self.liked_albums_json = json
            when TrackTypes::LIKED_USERS_ALBUMS_PUBLIC
              self.liked_users_albums_json = json
          end
        end
        version_tracker.clear

        # ok, now that the caches have been stored, save the versions
        base_cmd = "INSERT INTO c_versions(user_id, track_type, ver, user_last_touch_at) VALUES "
        end_cmd = " ON DUPLICATE KEY UPDATE ver = VALUES(ver), user_last_touch_at = VALUES(user_last_touch_at)"
        cache_man.fast_insert(ver_values, base_cmd, end_cmd)
      end

      # updates all of the specified trackers in a single insert/update
      # if the force_touch flag is set to true we will update the user_last_touch_at
      # time even if nothing changed - this is used to keep us from timing out a
      # given users cache.  The case where we do not set this to true is
      # when an individual cache is being fetched because just prior they
      # would have visited the index page which does the touch
      def update_trackers(force_touch)
        # and update the tracker state
        # convert to array for insert
        track_values = tracker.to_a
        base_cmd = "INSERT INTO c_tracks(user_id, tracked_id, tracked_id_type, track_type) VALUES "
        end_cmd = " ON DUPLICATE KEY UPDATE track_type = VALUES(track_type)"
        cache_man.fast_insert(track_values, base_cmd, end_cmd)

        # now a second update to mark all of our user_last_touch_at values so we are
        # kept in the cache.  We don't build it into the bulk insert above because
        # it is possible only some of the tracked items have been updated but
        # we want all of our trackers to show the same update time.  This is slightly
        # inefficient but we expect the typical user will have fewer than 100 tracked
        # things so the update should be extremely fast and this keeps the model simple.
        if (force_touch || track_values.length > 0)
          cmd = "UPDATE c_tracks SET user_last_touch_at = #{user_last_touch_at} WHERE user_id = #{user.id}"
          cache_man.execute(cmd)
        end
        tracker.clear
      end

      # load the current versions for the 3 types based on public or not
      def load_current_versions
        begin
          user_id = user.id
          cmd = "SELECT track_type, ver FROM c_versions WHERE user_id = #{user_id}"
          results = cache_man.execute(cmd)
          # take the results and put them in a hash so we can pull what we need
          ver_map = {}
          results.each do |r|
            track_type = r[0]
            ver = r[1]
            ver_map[track_type] = ver
          end

          # now that we have them mapped build a version object from them
          liked_users_albums = ver_map[TrackTypes::LIKED_USERS_ALBUMS_PUBLIC]
          if public
            my_albums = ver_map[TrackTypes::MY_ALBUMS_PUBLIC]
            liked_albums = ver_map[TrackTypes::LIKED_ALBUMS_PUBLIC]
          else
            my_albums = ver_map[TrackTypes::MY_ALBUMS]
            liked_albums = ver_map[TrackTypes::LIKED_ALBUMS]
          end

          return Versions.new(user, public, my_albums, liked_albums, liked_users_albums)

        rescue Exception => ex
          # ignore the exception and fall through to return 0 versions
        end

        return Versions.new(user, public)
      end

      # load or fetch from cache my_albums
      def load_my_albums
        track_type = get_my_albums_type
        if (self.my_albums_json = cache_fetch(track_type, current_versions.my_albums)) == nil
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
          add_tracked_user(user_id, track_type)

          # and update the cache with the albums
          current_versions.my_albums = updated_cache_version if current_versions.my_albums == 0
          self.my_albums = albums_to_hash(albums)
          version_tracker.add([track_type, self.my_albums, current_versions.my_albums])
        end
      end


      # load or fetch from cache the liked_albums
      def load_liked_albums
        track_type = get_liked_albums_type
        if (self.liked_albums_json = cache_fetch(track_type, current_versions.liked_albums)) == nil
          # not found in the cache, need to call the database to fetch them
          # we need to track all of them regardless of their current state because we
          # have to know of their existence so that when they do change to a visible
          # state we will know.  This means we fetch all and track all but only put
          # the visible ones into the cache
          albums = user.liked_albums

          # now build the list of ones we should put in the cache
          visible_albums = []
          albums.each do |album|
            next unless album.completed_batch_count > 0
            visible_albums << album if public == false || (album.privacy == 'public')
          end

          # add all the albums to the tracker even
          # if we can't see it currently so we have
          # a chance to see it change
          user_id = user.id
          albums.each do |album|
            add_tracked_album(album.id, track_type)
          end
          # and add a user_id tracker for ourselves so we know if we like or unlike an album
          add_tracked_album_like_membership(user_id, track_type)

          # and update the cache with the albums
          current_versions.liked_albums = updated_cache_version if current_versions.liked_albums == 0
          self.liked_albums = albums_to_hash(visible_albums)
          version_tracker.add([track_type, self.liked_albums, current_versions.liked_albums])
        end
      end

      # load or fetch from cache the liked_user_albums
      def load_liked_users_albums
        track_type = get_liked_users_albums_type
        if (self.liked_users_albums_json = cache_fetch(track_type, current_versions.liked_users_albums)) == nil
          # not found in the cache, need to call the database to fetch them
          albums = user.liked_users_public_albums

          # add the users we like to the tracker set
          # because it is a set, duplicates will be filtered
          # user_id, tracked_id, track_type
          albums.each do |album|
            add_tracked_user(album.user_id, track_type)
          end
          # and add a user_id tracker for ourselves so we know if we like or unlike a user
          user_id = user.id
          add_tracked_user_like_membership(user_id, track_type)

          # and update the cache with the albums
          current_versions.liked_users_albums = updated_cache_version if current_versions.liked_users_albums == 0
          self.liked_users_albums = albums_to_hash(albums)
          version_tracker.add([track_type, self.liked_users_albums, current_versions.liked_users_albums])
        end
      end

      # this is called after all the loads are done and
      # based on what happened with them, we update the
      # cache state to show that we are still around and
      # modify any dependencies
      def update_cache_state(force_touch)
        # update the trackers that we are dependent on
        # any change to these will invalidate our cache version
        # by setting it to 0 when they change
        update_trackers(force_touch)

        # update the caches and versions
        update_caches
      end

      # Pre load all the albums for the current state (public/private) from db into
      # cache only if we have no version info for that item.  When the caller returns to
      # get the actual data if it's not in the cache we fetch it for them at that time.
      def pre_fetch_albums
        load_my_albums() if current_versions.my_albums == 0
        load_liked_albums() if current_versions.liked_albums == 0
        load_liked_users_albums() if current_versions.liked_users_albums == 0

        # now update the cache state in the cache db
        update_cache_state(true)
      end

      # get albums from the cache or load from db if out of date
      def fetch_my_albums_json()
        load_my_albums()
        # now update the cache state in the cache db
        update_cache_state(false)

        # and return the albums
        return my_albums_json
      end

      def fetch_liked_albums_json()
        load_liked_albums()
        # now update the cache state in the cache db
        update_cache_state(false)

        # and return the albums
        return liked_albums_json
      end

      def fetch_liked_users_albums_json()
        load_liked_users_albums()
        # now update the cache state in the cache db
        update_cache_state(false)

        # and return the albums
        return liked_users_albums_json
      end

      # returns the type based on public or not
      def get_my_albums_type
        public ? TrackTypes::MY_ALBUMS_PUBLIC : TrackTypes::MY_ALBUMS
      end

      def get_liked_albums_type
        public ? TrackTypes::LIKED_ALBUMS_PUBLIC : TrackTypes::LIKED_ALBUMS
      end

      def get_liked_users_albums_type
        TrackTypes::LIKED_USERS_ALBUMS_PUBLIC
      end

      # this method returns the album as a map which allows us to perform
      # very fast json conversion on it
      def albums_to_hash(albums)
        fast_albums = []

        if albums.empty?
          # return a simple array data type
          return fast_albums
        end

        # first grab all the cover photos in one query
        # this populates the albums in place
        ::Album.fetch_bulk_covers(albums)

        # we keep a local map of the user_id to name because in most
        # cases the albums will have the same user - avoids lots of
        # Activerecord overhead
        # start with this user since likely to be referenced
        user_id_to_name_map[user.id.to_s] = user.username


        albums.each do |album|
          album_cover = album.cover
          album_id = album.id
          album_name = album.name
          album_updated_at = album.updated_at.to_i
          album_friendly_id = album.friendly_id

          # minimize the trips to the database since many
          # of the users will be the same for the the different albums
          album_user_id = album.user_id.to_s
          album_user_name = user_id_to_name_map[album_user_id]
          if album_user_name.nil?
              # don't have it, go to the db and get it
              album_user_name = album.user.username
              user_id_to_name_map[album_user_id] = album_user_name
          end

          hash_album = {
              :id => album_id,
              :name => album_name,
              :user_name => album_user_name,
              :user_id => album_user_id,
              :album_path => ApplicationController.album_pretty_path(album_user_name, album_friendly_id),
              :profile_album => album.type == 'ProfileAlbum',
              :c_url => album_cover.nil? ? nil : album_cover.thumb_url,
              :updated_at => album_updated_at
          }
          fast_albums << hash_album
        end

        return fast_albums
      end


    end

  end
end

