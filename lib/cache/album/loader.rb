module Cache
  module Album

    # This class handles the loading of the cache from albums and storing/fetching from
    # the cache.  It also tracks cache versions and sets up the tracked dependencies.
    class Loader
      attr_accessor :user, :user_id, :cache_man, :public, :current_versions, :user_id_to_name_map,
                    :tracker, :version_tracker, :user_last_touch_at, :album_loaders,
                    :my_album_loader, :liked_album_loader, :liked_users_album_loader, :invited_album_loader


      def initialize(cache_man, user, public)
        self.user = user
        self.user_id = user.id
        self.cache_man = cache_man
        self.public = public

        # make the albums loaders and put them in the
        # album_loaders array so we can do easy matching
        # operations
        self.album_loaders = []
        self.my_album_loader = MyAlbumLoader.new(self, Loader.compressed)
        self.album_loaders << self.my_album_loader
        self.liked_album_loader = LikedAlbumLoader.new(self, Loader.compressed)
        self.album_loaders << self.liked_album_loader
        self.liked_users_album_loader = LikedUserAlbumLoader.new(self, Loader.compressed)
        self.album_loaders << self.liked_users_album_loader
        self.invited_album_loader = InvitedAlbumLoader.new(self, Loader.compressed)
        self.album_loaders << self.invited_album_loader

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

      def self.compressed
        @@compressed ||= ZangZingConfig.config[:memcached_gzip]
      end

      def self.make_cache_key(user_id, album_type, ver)
        comp_flag = compressed ? "Z1" : "Z0"
        Manager::KEY_PREFIX + ".#{comp_flag}.#{album_type}.#{user_id}.#{ver}"
      end

      def cache
        Rails.cache
      end

      # get a new version, we use time in seconds
      # which should be ok.  Technically we could have
      # a collision if someone else was changing this user
      # at the same time but in most scenarios they would
      # end up with the same data anyways.
      def updated_cache_version
        return self.user_last_touch_at
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

      # updates the caches and does a single
      # database operation to update any changed cache versions
      def update_caches
        ver_values = []
        user_id = self.user.id
        use_compression = Loader.compressed
        version_tracker.each do |item|
          did_compress = use_compression
          album_type = item[0]
          albums = item[1]
          ver = item[2]
          key = Loader.make_cache_key(user_id, album_type, ver)

          json = JSON.fast_generate(albums)

          begin
            # compress the content once before caching: save memory and save nginx from compressing every response
            json = checked_gzip_compress(json, 'homepage.cache.corruption', "Key: #{key}, UserId: #{user_id}") if use_compression
            cache.write(key, json, :expires_in => Manager::CACHE_MAX_INACTIVITY)
            cache_man.logger.info "Caching #{key}"
          rescue Exception => ex
            # log the message but continue
            did_compress = false
            cache_man.logger.error "Failed to cache: #{key} due to #{ex.message}"
          end

          ver_values << [user_id, album_type, ver, user_last_touch_at]

          # now store the json for this cache for later retrieval
          # we hit them all to let them decide which one matches
          album_loaders.each do |album_loader|
            album_loader.store_json(json, did_compress, album_type)
          end
        end
        version_tracker.clear

        # ok, now that the caches have been stored, save the versions
        base_cmd = "INSERT INTO c_versions(user_id, track_type, ver, user_last_touch_at) VALUES "
        end_cmd = " ON DUPLICATE KEY UPDATE ver = VALUES(ver), user_last_touch_at = VALUES(user_last_touch_at)"
        cache_man.fast_insert(ver_values, base_cmd, end_cmd)
      end

      # load the current versions for the various types based on public or not
      def load_current_versions
        begin
          user_id = user.id
          cmd = "SELECT track_type, ver FROM c_versions WHERE user_id = #{user_id}"
          results = cache_man.execute(cmd)
          # take the results and put them in a hash so we can pull what we need
          ver_map = {}
          results.each do |r|
            album_type = r[0]
            ver = r[1]
            ver_map[album_type] = ver
          end

          # the ver_map contains the album_type to version data
          return Versions.new(user, public, ver_map)

        rescue Exception => ex
          # ignore the exception and fall through to return 0 versions
        end

        return Versions.new(user, public)
      end

      # load or fetch from cache my_albums
      def load_my_albums
        my_album_loader.load_albums
      end

      # load or fetch from cache the liked_albums
      def load_liked_albums
        liked_album_loader.load_albums
      end

      # load or fetch from cache the liked_user_albums
      def load_liked_users_albums
        liked_users_album_loader.load_albums
      end

      # load or fetch from cache invited_albums
      def load_invited_albums
        invited_album_loader.load_albums
      end

      # this is called after all the loads are done and
      # based on what happened with them, we update the
      # cache state to show that we are still around and
      # modify any dependencies
      def update_cache_state(force_touch)
        # the order of these operations is critical to
        # maintaining a consistent cache.  Since the
        # invalidation logic first deletes the trackers
        # and then zeroes the versions we must avoid
        # a race condition causing us to end up with
        # a valid version but no trackers. Therefore,
        # we must first update the cache (and version)
        # before updating the trackers.  This ensures
        # that we always have trackers whenever the
        # cache version is non zero.  If the invalidation
        # code runs in between our update_caches and
        # update_caches the worst case scenario is
        # that we have to rebuild the cache on the next
        # call.

        # update the caches and versions first
        update_caches

        # update the trackers that we are dependent on
        # any change to these will invalidate our cache version
        # by setting it to 0 when they change
        # doing this last ensures we always have valid
        # trackers - the edge case is we can end up
        # with version trackers and a version of zero
        # which is redundant but does no harm
        update_trackers(force_touch)

      end

      # Pre load all the albums for the current state (public/private) from db into
      # cache only if we have no version info for that item.  When the caller returns to
      # get the actual data if it's not in the cache we fetch it for them at that time.
      def pre_fetch_albums
        # walk the array of loaders and call each one that has no version
        album_loaders.each do |album_loader|
          if album_loader.current_version == 0
            album_loader.load_albums
          end
        end

        # now update the cache state in the cache db
        update_cache_state(true)
      end


      include PrettyUrlHelper
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
              :album_path => album_pretty_path(album_user_name, album_friendly_id),
              :profile_album => album.type == 'ProfileAlbum',
              :c_url => album_cover.nil? ? nil : album_cover.thumb_url,
              :photos_count => album.photos_count,
              :photos_ready_count => album.photos_ready_count,
              :cache_version => album.cache_version.to_i,
              :my_role => album.my_role # valid values are Viewer, Contrib, Admin
          }
          fast_albums << hash_album
        end

        return fast_albums
      end


    end

  end
end

