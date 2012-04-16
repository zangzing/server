class ActivitiesController < ApplicationController

  # The activities view for an album
  # @album is set by the require_album before_filter
  def album_index
    return unless require_album(true) && require_album_viewer_role
    @activities = @album.activities
  end

  def user_index
    return unless require_nothing
    begin
      @user = User.find(params[:user_id])
      @activities = @user.activities
      @user_is_auto_follow = User.auto_like_ids.include?( @user.id )
      @is_homepage_view = true
    rescue ActiveRecord::RecordNotFound => e
      user_not_found_redirect_to_homepage_or_potd
      return
    end

  end

    # Return the activity meta data for a given user.
    # Returns an array of activities (activities are photos for now)
    # ordered by 'latest_activity DESC'
    #
    # This is called as (GET):
    #
    # /zz_api/users/:user_id/activity
    #
    #
    # Returns the album meta data in the following form:
    #
    # {
    # }


  def zz_api_user_activity
    return unless require_same_user_json
    zz_api_self_render do
      activity_loader
    end
  end


  private

  ACTIVITY_QUERY= <<EOS
        SELECT
        photos.*,
        GREATEST( IFNULL(photos.updated_at,' '),  IFNULL(MAX(comments.created_at),' '))as latest_activity,
        IF( comments.id is NULL, "Upload", "Comment") as activity_kind,
        IF( comments.id is NULL, photos.user_id, comments.user_id) as latest_activity_by_user_id,
        IF( comments.id is NULL, 1, count(*)+1) as activity_count,
        IFNULL(like_counters.counter, 0) as like_count
        FROM photos
        JOIN albums ON albums.id = photos.album_id AND albums.user_id = ?
        LEFT OUTER JOIN  comments     ON comments.subject_id = photos.id
        LEFT OUTER JOIN like_counters ON like_counters.subject_type = "P" AND like_counters.subject_id = photos.id
        GROUP BY photos.id
        ORDER BY latest_activity desc
EOS

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


  # returns a json string of the current user photos
  def activity_loader
    user = current_user
    gzip_compress = ZangZingConfig.config[:memcached_gzip]
    compressed = gzip_compress
    ver = params[:ver]
    cache_version_key = "This-is-the-only-activity-cache-key" || 0
    albums = params[:albums]
    page = params[:page]
    size = params[:size]

    comp_flag = gzip_compress ? "Z1" : "Z0"

    # change the Photo.hash_schema_version method anytime you make a change
    # to the basic cache structure such as adding new q
    # data to the returned info
    cache_key = "User.Acticity.#{comp_flag}.#{user.id}.#{cache_version_key}"

    #disable caching for now
    #json = CacheWrapper.read(cache_key, true)
    #if(json.nil?)
        # not found so pull from db and cache
        #photos_as_activities  = Photo.find_by_sql( [ACTIVITY_QUERY, user.id] )
        photos_as_activities  = Photo.find_by_sql( [ACTIVITY_QUERY2, albums, page.to_i,size.to_i ])
        json = JSON.fast_generate(hash_photos_as_activities(photos_as_activities))
        compressed, json = cache_photos_as_activities_json(cache_key, json, gzip_compress)
    #end
    render_cached_json(json, false , compressed)
  end


  def hash_photos_as_activities(photos)
    if photos.is_a?(Array) == false
      hashed_photos = hash_one_photo_as_activity(photos)
    else
      hashed_photos = []
      photos.each do |photo|
        hashed_photo = hash_one_photo_as_activity(photo)
        hashed_photos << hashed_photo
      end
    end
    return hashed_photos

  end

  # this method packages up the fields
  # we care about for return via json
  def hash_one_photo_as_activity(photo)
      #first obtain the standard photo hash, then add the activity stuff
      hashed_photo = Photo.hash_one_photo( photo )
      hashed_photo[:latest_activity]= photo.latest_activity
      hashed_photo[:activity_kind] = photo.activity_kind
      hashed_photo[:latest_activity_by_user_id] = photo.latest_activity_by_user_id
      hashed_photo[:like_count] = photo.like_count
      hashed_photo
  end

  def cache_photos_as_activities_json(cache_key, json, gzip_compress)
      compressed = false
      begin
        #compress the content once before caching: save memory and save nginx from compressing every response
        json = checked_gzip_compress(json, 'photos_as_activities.cache.corruption', "Key: #{cache_key}, UserId: #{@album.user_id}") if gzip_compress
        compressed = gzip_compress
        CacheWrapper.write(cache_key, json, {:expires_in => 72.hours, :log => true})
      rescue Exception => ex
        # log the message but continue
        logger.error "Failed to cache: #{cache_key} due to #{ex.message}"
      end
      [compressed, json]
  end

end
