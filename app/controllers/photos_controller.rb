require "zz_env_helpers"


class PhotosController < ApplicationController
  ssl_allowed :agent_create, :agent_index

  skip_before_filter :verify_authenticity_token,  :only =>   [ :agent_index, :agent_create, :upload_fast, :simple_upload_fast]

  
  before_filter :require_user,                    :only =>   [ :destroy, :update, :position, :async_edit, :async_rotate_left, :async_rotate_right, :download ]  #for interactive users
  before_filter :oauth_required,                  :only =>   [ :agent_create, :agent_index ]   #for agent
  # oauthenticate :strategies => :two_legged, :interactive => false, :only =>   [ :upload_fast ]

  before_filter :require_album,                   :only =>   [ :agent_create, :index, :movie, :photos_json, :photos_json_invalidate ]
  before_filter :require_photo,                   :only =>   [ :destroy, :update, :position, :async_edit, :async_rotate_left, :async_rotate_right, :download ]

  before_filter :require_album_admin_role,                :only =>   [ :update, :position ]
  before_filter :require_photo_owner_or_album_admin_role, :only =>   [ :destroy, :async_edit, :async_rotate_left, :async_rotate_right ]
  before_filter :require_album_contributor_role,          :only =>   [ :agent_create  ]
  before_filter :require_album_viewer_role,               :only =>   [ :index, :movie, :photos_json  ]


  # Used by the agent to create photos duh?
  # logged in via oauth
  # @album set by require_album
  def agent_create
start_time = Time.now
    if params[:source_guid].nil?
      render :json => "source_guid parameter required. Unable to create photos", :status=>400 and return
    end

    user_id           = current_user.id
    album_id          = @album.id
    agent_id          = params[:agent_id]
    photos            = []
    source_guid_map   = params[:source_guid]
    photo_count       = source_guid_map.length
    caption_map       = params[:caption]
    file_size_map     = params[:size]
    capture_date_map  = params[:capture_date]
    source_map        = params[:source]
    rotate_to         = params[:rotate_to]    # optional initial rotation leave null to use rotation in file

    # optimize by ensuring we have the number of ids we need up front
    current_id = Photo.get_next_id(photo_count)
    current_batch = UploadBatch.get_current_and_touch( user_id, album_id )
    batch_id = current_batch.id

    (0...photo_count).each do |index|
      i_s = index.to_s
      photo = Photo.new_for_batch(current_batch,  {
                                    :id                =>   current_id,
                                    :album_id          =>   album_id,
                                    :user_id           =>   user_id,
                                    :upload_batch_id   =>   batch_id,
                                    :agent_id          =>   agent_id,
                                    :source_thumb_url  =>   Photo.make_agent_source('thumb', current_id, album_id),
                                    :source_screen_url =>   Photo.make_agent_source('screen', current_id, album_id),
                                    :source_guid       =>   source_guid_map[i_s],
                                    :source            =>   safe_hash_default(source_map, i_s, nil),
                                    :rotate_to         =>   rotate_to,
                                    :caption           =>   safe_hash_default(caption_map, i_s, ""),
                                    :image_file_size   =>   file_size_map[i_s],
                                    :capture_date      =>   Time.at( max_safe_epoch_time(safe_hash_default(capture_date_map, i_s, 0).to_i) )
                                    }
                                    )
      current_id += 1
      photos << photo
    end

    if (photos.count > 0)
      results = Photo.batch_insert(photos)

      # the results above tells you if validations failed, not if the actual call failed
      if results.failed_instances.count > 0
        failed_photo = results.failed_instances[0]
        render :json => failed_photo.errors, :status=>500 and return
      end
    end

    json_str = Photo.to_json_lite(photos)

end_time = Time.now
puts "Time in agent_create with #{photo_count} photos: #{end_time - start_time}"

    logger.debug json_str

    render :json => json_str
  end


  def agent_index
    begin
      @photos = Photo.all(:conditions => ["agent_id = ? AND state = ?", params[:agent_id], 'assigned'])
      render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :album_id])

    rescue ActiveRecord::StatementInvalid => ex
      #this seems to mean connection issue with database
      render :json => ex.to_s, :status=>500

    rescue Exception => ex
      render :json => ex.to_s, :status=>500

    end
  end

  def simple_upload_fast
    persistence_token = params[:user_credentials].split('::')[0]
    user = User.find_all_by_persistence_token(persistence_token)
    if user
      user = user[0]
    else
      render :text=>'unauthorized', :status=>401
      return
    end

    album = Album.find(params[:album_id])

    current_batch = UploadBatch.get_current_and_touch( user.id, album.id )

    photo = Photo.new_for_batch(current_batch, {
        :id => Photo.get_next_id,
        :user_id => user.id,
        :album_id => album.id,
        :upload_batch_id => current_batch.id,
        :caption => params[:fast_local_image][0][:original_name],
        :source => params[:source],
        :rotate_to => params[:rotate_to],
        :source_guid => "simpleuploader:"+UUIDTools::UUID.random_create.to_s})

    photo.file_to_upload = params[:fast_local_image][0][:filepath]
    photo.save()
    render :text=>'', :status=>200

  end


  def upload_fast
    #nginx add params so it breaks oauth. use this validation to ensure it is coming from nginx
    #currently we only handle one photo attachment but the input is structured to send multiple
    #as is done with the sendgrid#import_fast

    if params[:fast_upload_secret] == "this-is-a-key-from-nginx" && (attachments = params[:fast_local_image]) && attachments.count == 1
      begin
        @photo = Photo.find(params[:id])
        @album = @photo.album
        fast_local_image = attachments[0] # extract only the first one
        @photo.file_to_upload = fast_local_image['filepath']
        if @photo.save
          render :json => @photo.to_json(:only =>[:id, :agent_id, :state]), :status => 200 and return
        else
          render :json => @photo.errors, :status=>400
        end

      rescue ActiveRecord::StatementInvalid => ex
        #this seems to mean connection issue with database
        #give the agent a chance  to retry
        render :json => ex.to_s, :status=>500
        logger.info small_back_trace(ex)

      rescue Exception => ex
        # a status in the 400 range tells the agent to stop trying
        # our default if we don't explicitly expect the error is to not
        # try again
        render :json => ex.to_s, :status=>400
        logger.info small_back_trace(ex)
      end
    else
      # call did not come through remapped upload via nginx so reject it
      render :json => "Invalid upload_fast arguments.", :status=>400
    end

  end

  #deletes a photo
  #@photo & @album are set by require_photo beofre filter
  def destroy
    cover_id = @album.cover_photo_id
    if cover_id == @photo.id
      @album.cover_photo_id = nil
      @album.save
    end
    respond_to do |format|
      format.html do
        if !@photo.destroy
          flash[:error] = "Unable to delete photo!"
        end
        redirect_to @album
      end
      format.json do
        if !@photo.destroy
          render :json => @photo.errors, :status=>500
        end
        render :json => "Photo deleted".to_json
      end
    end
  end

  # used by facebook and google crawlers but not by interactive users
  # displays all the photos in an album
  # @album is set by require_album before_filter
  def index

    if(!params[:user_id])
      redirect_to album_pretty_url(@album)
    else
      @title = CGI.escapeHTML(@album.name)
      @photos = @album.photos
      if params['_escaped_fragment_'] #this is google or facebook
        @photo = Photo.find(params['_escaped_fragment_'])
      end
      render 'photos'
    end
  end

  # returns the  movie view
  # @album is set by before_filter require_album
  def movie
    @photos = @album.photos
    render 'movie', :layout => false
  end

  # returns a json string of the album photos
  # @album is set by before_filter require_album
  def photos_json
     gzip_compress = ZangZingConfig.config[:memcached_gzip]
     compressed = gzip_compress
     if stale?(:etag => @album)

      cache_version = @album.cache_version
      cache_version = 0 if cache_version.nil?

      comp_flag = gzip_compress ? "Z1" : "Z0"
      # change the vN parm below anytime you make a change
      # to the basic cache structure such as adding new
      # data to the returned info
      cache_key = "Album.Photos.#{comp_flag}.v2.#{@album.id}.#{cache_version}"

      logger.debug 'cache key: ' + cache_key
      json = Rails.cache.read(cache_key)

      if(json.nil?)
        json = Photo.to_json_lite(@album.photos)

        begin
          #compress the content once before caching: save memory and save nginx from compressing every response
          json = checked_gzip_compress(json, 'album.cache.corruption', "Key: #{cache_key}, AlbumId: #{@album.id}, UserId: #{@album.user_id}") if gzip_compress
          Rails.cache.write(cache_key, json, :expires_in => 72.hours)
          compressed = gzip_compress
          logger.debug 'caching photos_json: ' + cache_key
        rescue Exception => ex
          # log the message but continue
          logger.error "Failed to cache: #{cache_key} due to #{ex.message}"
          compressed = false
        end

      else
        logger.debug 'using cached photos_json: ' + cache_key
      end

      expires_in 1.year, :public => @album.public?
      response.headers['Content-Encoding'] = "gzip" if compressed
      render :json => json
    else
      logger.debug 'etag match, sending 304'
    end
  end

  # invalidate the current cached data for the photos in this album
  # we need this hack because we have seen corrupt json data being returned
  # from the cache so either issue with ruby,gzip, or memcached
  def photos_json_invalidate
    Album.change_cache_version(@album.id)
    render :json => ''
  end


  # updates photo attributes
  # @photo is set in require_photo before filter
  def update
    if @photo && @photo.update_attributes( params[:photo] )
      flash[:notice] = "Photo Updated!"
      render :text => 'Success Updating Photo', :status => 200, :layout => false
    else
      errors_to_headers( @photo )
      render :text => 'Photo update did not succeed', :status => 500, :layout => false
    end
  end

  # Used by the photogrid to notify changes in the album order when a photo is dragged and dropped
  # expects params[ :before_id ] and params[ :after_id ]
  # @photo is set by require_photo before_filter
  def position
    @photo.position_between( params[:before_id], params[:after_id])
    render :nothing => true
  end

  # Called to start an async rotate
  #
  # Expects param: rotate_to=degs
  # degs is specified as the clockwise rotation from 0, so 90 deg right
  # is 90, 90 deg left is 270, upside down is 180.  You should examine
  # the current rotation on the photo to determine the absolute rotation.
  # for instance if the photo is already rotated 90 degreees and you want to
  # rotate 90 more you need to pass 180.  You can obtain the current
  # rotation via the photos.json
  #
  def async_edit
    begin
      rotate_to = params[:rotate_to]
      # queue up the rotate
      response_id = @photo.start_async_edit(rotate_to)
    rescue Exception => ex
      render_json_error(ex)
      return
    end
    render_async_response_json response_id
  end

  def async_rotate_left
    rotate_to = @photo.rotate_to.to_i - 90
    if(rotate_to == -90)
      rotate_to = 270
    end

    params[:rotate_to] = rotate_to

    async_edit
  end


  def async_rotate_right
    rotate_to = @photo.rotate_to.to_i + 90
    if(rotate_to == 360)
      rotate_to = 0
    end

    params[:rotate_to] = rotate_to

    async_edit
  end






  # @photo and @album are  set by require_photo before_filter
  def download
    unless  @album.can_user_download?( current_user )
      flash.now[:error] = "Only Authorized Album Group Memebers can download photos"
      if request.xhr?
        head :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end

    if @photo && @photo.ready?
      type = @photo.image_content_type.split('/')[1]
      extension = case( type )
                    when 'jpg' then 'jpeg'
                    when 'tiff' then 'tif'
                    else type
                  end
      name = ( @photo.caption.nil? || @photo.caption.length <= 0 ? Time.now.strftime( '%y-%m-%d-%H-%M-%S' ): @photo.caption )
      filename = "#{name}.#{extension}"
      url = @photo.original_url.split('?')[0]

      zza.track_event("photos.download.original")
      Rails.logger.debug("Original download: #{ url}")

      if (browser.ie? && request.headers['User-Agent'].include?('NT 5.1'))
        # tricks to get IE to handle correctly
        # request.headers['Cache-Control'] = 'must-revalidate, post-check=0, pre-check=0'
        x_accel_redirect(url, :type=>"image/#{type}") and return
      else
        x_accel_redirect(url, :filename => filename, :type=>"image/#{type}") and return
      end
    else
      flash[:error]="Photo has not finished Uploading"
      head :not_found and return
    end
  end


  private
  #
  # To be run as a before_filter
  # sets @photo to be Photo.find( params[:id ])
  # set @album ot @photo.album
  # params[:id] required, must be present and be a valid photo_id.
  def require_photo
    begin
      @photo = Photo.find( params[:id ])  #will trhow exception if params[:id] is not defined or photo not found
      @album = @photo.album
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:error] = "This operation requires a photo, we could not find one because: "+e.message
      if request.xhr?
        head :not_found
      else
        render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
      end
      return false
    end
  end

  #
  # To be run as a before_filter
  # sets @album
  # params[:album_id] required, it must be present and be a valid album_id.
  # params[:user_id]  optional, if present it will be used as a :scope for the finder
  # Throws ActiveRecord:RecordNotFound exception if params[:id] is not present or the album is not found
  def require_album
    begin
      #will trhow exception if params[:album_id] is not defined or album not found
      if params[:user_id]
        @album = User.find( params[:user_id] ).albums.find(params[:album_id] )
      else
        @album = Album.find( params[:album_id] )
      end
    rescue ActiveRecord::RecordNotFound => e
      flash.now[:error] = "This operation requires an album, we could not find one because: "+e.message
      if request.xhr?
        head :not_found
      else
        render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
      end
      return false
    end
  end

  #
  # To be run as a before_filter
  # Requires
  # @photo is the photo to be acted upon
  # current_user is the user we are evaluating
  def require_photo_owner_or_album_admin_role
    unless  @photo.user.id == current_user.id || @photo.album.admin?( current_user.id ) || current_user.support_hero?
      flash.now[:error] = "Only Photo Owners or Album Admins can perform this operation"
      response.headers['X-Errors'] = flash[:error]
      if request.xhr?
        head :not_found
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end
  end


end
