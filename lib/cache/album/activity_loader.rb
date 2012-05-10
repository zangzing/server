module Cache
  module Album
    # this class represents a generic interface that album loaders share
    class ActivityLoader< BaseAlbumLoader

      def match_type(album_type)
        album_type == AlbumTypes::ACTIVITY || album_type == AlbumTypes::ACTIVITY_PUBLIC
      end

      def album_type
        public ? AlbumTypes::ACTIVITY_PUBLIC : AlbumTypes::ACTIVITY
      end

      # load or fetch from cache my_albums
      def load_albums
        if (self.json = cache_fetch).nil?
          # not found in the cache, need to call the database to fetch them

          # TODO:make the public or not distinction

          #MY ALBUMS
          my_album_ids         = load_my_album_ids(false)
          # add ourselves to the track set because we want to be
          # invalidated if our albums change
          # user_id, tracked_id, track_type
          user_id = user.id
          add_tracked_user(user_id, album_type)

          #LIKED ALBUMS
          liked_album_ids      = load_liked_album_ids
          # and add a user_id tracker for ourselves so we know if we like or unlike an album
          add_tracked_album_like_membership(user_id, album_type)


          #LIKED USER ALBUMS
          liked_user_albums = load_liked_user_albums
          # add the users we like to the tracker set
          # because it is a set, duplicates will be filtered
          # user_id, tracked_id, album_type
          liked_user_album_ids = []
          liked_user_albums.each do |album|
            add_tracked_user(album.user_id, album_type)
            liked_user_album_ids << album.id
          end
          # and add a user_id tracker for ourselves so we know if we like or unlike a user
          add_tracked_user_like_membership(user_id, album_type)



          #INVITED ALBUMS
          invited_albums    = load_invited_albums
          visible_invited_album_ids = []
          invited_albums.each do |album|
            next if (user_id == album.user_id)  # don't show our own albums
            album_id = album.id
            album.my_role = album_roles[album_id]
                                                # track the ones we care about if they change
            add_tracked_album(album_id, album_type)
            visible_invited_album_ids << album.id
          end


          #Assemble all album_ids
          album_ids =  my_album_ids + liked_album_ids + liked_user_album_ids + visible_invited_album_ids
          album_ids.uniq!
          photos_as_activities  = Photo.find_by_sql( [ACTIVITY_QUERY2, album_ids, 0,20 ])



          # and update the cache with the albums
          self.current_version = updated_cache_version if current_version == 0
          # = albums_to_hash(albums)
          self.albums = hash_photos_as_activities(photos_as_activities)
          version_tracker.add([album_type, self.albums, current_version])
        end
      end

      def current_version_key
         "#{hash_schema_version}.#{current_versions.version(self.album_type)}"
      end


      def hash_schema_version
        "V2.0"
      end

      def hash_photos_as_activities(photos)
        if photos.is_a?(Array)
          hashed_photos = []
          photos.each do |photo|
            hashed_photo = hash_one_photo_as_activity(photo)
            hashed_photos << hashed_photo
          end
        else
          hashed_photos = hash_one_photo_as_activity(photos)
        end
        hashed_photos
      end

       # this method packages up the fields
       # we care about for return via json
       def hash_one_photo_as_activity(photo)
           #first obtain the standard photo hash, then add the activity stuff
           hashed_photo = Photo.hash_one_photo( photo )
           hashed_photo[:created_at]= photo.latest_activity
           hashed_photo[:kind] = photo.activity_kind
           hashed_photo[:by_user_id] = photo.latest_activity_by_user_id
           hashed_photo[:like_count] = photo.like_count
           hashed_photo
       end

       def cache_photos_as_activities_json(cache_key, json, gzip_compress)
           compressed = false
           begin
             #compress the content once before caching: save memory and save nginx from compressing every response
             json = checked_gzip_compress(json, 'photos_as_activities.cache.corruption', "Key: #{cache_key}") if gzip_compress
             compressed = gzip_compress
             CacheWrapper.write(cache_key, json, {:expires_in => 72.hours, :log => true})
           rescue Exception => ex
             # log the message but continue
             logger.error "Failed to cache: #{cache_key} due to #{ex.message}"
           end
           [compressed, json]
       end


       def load_invited_albums
         # get all the acls for this user so we can find albums in one query
         # also need to track album_id => role so after we have the album we
         # can attach that local data to each album result
         album_ids = []
         tuples = AlbumACL.get_acls_for_user(user.id, AlbumACL::VIEWER_ROLE, false)
         tuples.each do |tuple|
           album_ids << tuple.acl_id.to_i
         end
         ::Album.where( "id IN (?)", album_ids)
       end

       def load_liked_user_albums
         albums = user.liked_users_public_albums
         # now build the list of ones we should put in the cache
         # don't put in ones that belong to us
         user_id = user.id
         visible_albums = []
         albums.each do |album|
           next if user_id == album.user_id
           visible_albums << album if public == false || (album.privacy == 'public')
         end
         visible_albums
       end

       def load_liked_album_ids
         albums = user.liked_albums
         user_id = user.id
         # now build the list of ones we should put in the cache
         # don't put in ones that haven't been completed or belong to us
         # if someone is fetching our public view, only show public albums
         visible_album_ids = []
         albums.each do |album|
           next if (album.completed_batch_count == 0) || (user_id == album.user_id)
           visible_album_ids << album.id if public == false || (album.privacy == 'public')
         end
         visible_album_ids
       end

       def load_my_album_ids( public )
         if public
             albums = user.albums.where("privacy = 'public' AND completed_batch_count > 0")
         else
             albums = user.albums
         end
         album_ids = []
         albums.each do |album|
           album_ids << album.id
         end
         album_ids
       end

  ACTIVITY_QUERY2 = <<EOS
             SELECT
             photos.*,
             GREATEST( IFNULL(photos.updated_at,' '),  IFNULL(MAX(comments.created_at),' '))as latest_activity,
             IF( comments.id is NULL, "Upload", "Comment") as activity_kind,
             IF( comments.id is NULL, photos.user_id, comments.user_id) as latest_activity_by_user_id,
             IF( comments.id is NULL, 1, count(*)+1) as activity_count,
             IFNULL(like_counters.counter, 0) as like_count
             FROM photos
             JOIN albums ON albums.id = photos.album_id AND albums.id in ( ? )
             LEFT OUTER JOIN  comments     ON comments.subject_id = photos.id
             LEFT OUTER JOIN like_counters ON like_counters.subject_type = "P" AND like_counters.subject_id = photos.id
             GROUP BY photos.id
             ORDER BY latest_activity desc
             LIMIT ?,?
EOS


    end
  end
end
