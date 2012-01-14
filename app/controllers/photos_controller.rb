require "zz_env_helpers"


class PhotosController < ApplicationController
  ssl_allowed :agent_create, :agent_index
  skip_before_filter :verify_authenticity_token,  :only =>   [ :agent_index, :agent_create, :upload_fast, :simple_upload_fast]

  # Used by the agent to create photos duh?
  # logged in via oauth
  # @album set by require_album
  def agent_create
    return unless oauth_required && require_user && require_album(true) && require_album_contributor_role
    begin
      user_id           = current_user.id
      album_id          = @album.id
      agent_id          = params[:agent_id]
      source_guid_map   = params[:source_guid]
      photo_count       = source_guid_map.length
      caption_map       = params[:caption]
      file_size_map     = params[:size]
      capture_date_map  = params[:capture_date]
      source_map        = params[:source]
      rotate_to_map     = params[:rotate_to]    # optional initial rotation leave null to use rotation in file
      rotate_to_map = rotate_to_map ? rotate_to_map : {}

      # transform the params into the api form
      create_photos = []
      (0...photo_count).each do |index|
        i_s = index.to_s
        create_photo = {
            :source_guid => source_guid_map[i_s],
            :caption => safe_hash_default(caption_map, i_s, ""),
            :size => file_size_map[i_s],
            :capture_date => safe_hash_default(capture_date_map, i_s, 0),
            :source => safe_hash_default(source_map, i_s, nil),
            :rotate_to => rotate_to_map[i_s]
        }
        create_photos << create_photo
      end
      args = {
          :agent_id => agent_id,
          :photos => create_photos
      }
      # all prepped let the low level api do the real work
      photos = batch_photo_create(user_id, album_id, true, args)
    rescue ArgumentError => ex
      render :json => "source_guid parameter required. Unable to create photos", :status=>400
      return
    end

    json_str = Photo.to_json_lite(photos)
    render :json => json_str
  end

  # The batch photo creation process for the zz_api.
  # This is very similar to how the agent operates where
  # we first create placeholder photos and then
  # populate them later with the upload method.
  #
  # This is called as:
  #
  # /zz_api/albums/:album_id/photos/create_photos
  #
  # Where :album_id is the album you are creating the photos in
  # :user_id is derived from your current account session.
  #
  # You must have permission to add photos to this album.  This means that you are either the owner (your user id matches
  # that of the album), a contributor (checking your role on the album as being Contrib or Admin),
  # or the all_can_contrib flag in the albums is set to true.
  #
  # the expected parameters are:
  #
  # {
  # :agent_id => unique string generated by the calling client that
  #           represents a unique single instance of that app
  # :photos => array of photos to create with the following params
  #   [
  #     {
  #     :source_guid => identifies this unique photo
  #     :caption => the caption for this photo
  #     :file_size => expected size for this file when uploaded
  #     :capture_date => date file was captured in epoch secs, should use create date if not known
  #     :source => identifier as to the upload source (such as iphone, fs.osx, etc)
  #     :rotate_to => optional initial rotation - nil if no rotate
  #     :crop_to => optional initial cropping hash - nil if no cropping
  #       {
  #       :top => fractional percent from top (i.e. 0.15 for 15%)
  #       :left => fraction from left
  #       :bottom => fraction from top on where to crop (i.e if you want to crop 15% from bottom you would pass 1-.15 or .85)
  #       :right => fraction from left on where to crop (i.e if you want to crop 20% from right you would pass 1-.20 or .80)
  #       }
  #     }
  #   ...
  #   ]
  # }
  #
  #
  # Returns an array of photo objects in the following form:
  #
  # [
  #   {
  #   :id =>  The photo id
  #   :user_id => User id that created this photo
  #   :album_id => The album id this photo belongs to
  #   :source_guid => The source guid supplied on the create
  #   }
  #   ...
  # ]
  #
  #
  def zz_api_create_photos
    return unless require_user && require_album(true) && require_album_contributor_role

    zz_api do
      user_id           = current_user.id
      album_id          = @album.id
      photos = batch_photo_create(user_id, album_id, false, params)
      hashed_photos = photos.map { |photo| {
          :id => photo.id,
          :user_id => photo.user_id,
          :album_id => photo.album_id,
          :source_guid => photo.source_guid,
      } }
    end
  end


  def pending_photos
    Photo.all(:conditions => ["user_id = ? AND agent_id = ? AND state = ?", current_user.id, params[:agent_id], 'assigned'])
  end

  def agent_index
    return unless oauth_required && require_user
    begin
      @photos = pending_photos
      render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :album_id])

    rescue Exception => ex
      render :json => ex.to_s, :status=>500

    end
  end

  #
  # returns the photos that are pending upload
  # this returns a very minimal set of data to
  # the caller.  Called with:
  #
  # /zz_api/photos/:agent_id/pending_uploads
  #
  # where :agent_id is a unique id tied to that instance
  # of your application
  #
  # returns results as an array of:
  # [
  #   {
  #   :id => photo id
  #   :album_id => album id this photo belongs to
  #   }
  #   ...
  # ]
  #
  def zz_api_pending_uploads
    return unless require_user
    zz_api do
      photos = pending_photos
      hashed_photos = photos.map { |photo| {:id => photo.id, :album_id => photo.album_id} }
    end
  end


  def simple_upload_fast
    # because we are called via flash we don't get the user_credentials cookie set
    # and instead it gets passed as part of the posted data so we manually extract
    # it and then set it up as current_user
    persistence_token = params[:user_credentials].split('::')[0]
    user = User.find_all_by_persistence_token(persistence_token)
    user = user[0] if user
    self.current_user = user
    return unless require_user && require_album(true) && require_album_contributor_role

    album = @album

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

  # Upload a file for a given photo id -
  # Called in the form:
  #
  # /service/photos/:photo_id/upload - for the agent
  # /zz_api/photos/:photo_id/upload - for the zz_api
  #
  # For zz_api, the field name used to specify the attachment should be in the form:
  # photo[:photo_id] (i.e. photo[12345]) - this is not strictly a requirement but
  # this should be used since we may expand to multiple file uploads at some point.
  #
  # An example test upload using curl would be:
  # curl --form photo[169911144848]=@/myphotos/test.jpg http://localhost/zz_api/photos/169911144848/upload
  #
  # When called by the standard agent interface we return direct json with:
  # {
  # :id => the photo id we just updated
  # :agent_id => the agent we were called by
  # :state => the current state (uploading, ready, etc)
  # }
  # When called via zz_api we return with:
  # {
  # :id => the photo id we just updated
  # :state => the current state (uploading, ready, etc)
  # }
  #
  # if an error occurs, we return a direct json string in the agent case
  # and if called via zz_api we return the standard json error form with a status of
  # 509 and the json containing the real error status - the data can either be a single
  # string with the error message or an array of strings
  #
  # a real error code of 500 means the error is temporary and you should retry the upload
  # later - an error code in the 400 range means a non recoverable error
  def upload_fast
    # this is a cheat to get the current user since nginx prevents us from getting it via oauth
    # we grab the photo passed which has the user which we then set to current_user so the
    # rest of the calls that require current_user work as expected
    return unless require_photo
    self.current_user = @photo.user
    return unless require_user && require_album_contributor_role

    #nginx adds params so it breaks oauth. use this validation to ensure it is coming from nginx
    #currently we only handle one photo attachment but the input is structured to send multiple
    #as is done with the sendgrid#import_fast
    if params[:fast_upload_secret] == "this-is-a-key-from-nginx" && (attachments = params[:fast_local_image]) && attachments.count == 1
      begin
        fast_local_image = attachments[0] # extract only the first one
        @photo.file_to_upload = fast_local_image['filepath']
        if @photo.save
          json = zz_api_call? ? @photo.to_json(:only =>[:id, :state]) : @photo.to_json(:only =>[:id, :agent_id, :state])
          render :json => json, :status => 200
          return
        else
          error = @photo.errors
          status = 400
        end

      rescue ActiveRecord::StatementInvalid => ex
        #this seems to mean connection issue with database
        #give the agent a chance  to retry
        error = ex.to_s
        status = 500
        logger.info small_back_trace(ex)

      rescue Exception => ex
        # a status in the 400 range tells the agent to stop trying
        # our default if we don't explicitly expect the error is to not
        # try again
        error = ex.to_s
        status = 400
        logger.info small_back_trace(ex)
      end
    else
      # call did not come through remapped upload via nginx so reject it
      error = "Invalid upload_fast arguments."
      status = 400
    end

    if zz_api_call?
      render_json_error(nil, error, status)
    else
      render :json => error, :status => status
    end
  end

  #deletes a photo
  #@photo & @album are set by require_photo beofre filter
  def destroy
    return unless require_user && require_photo && require_photo_owner_or_album_admin_role
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

  def index
    return unless require_album(true) && require_album_viewer_role
    if(!params[:user_id])
      redirect_to album_pretty_url(@album)
    else
      @title = CGI.escapeHTML(@album.name)
      @photos = @album.photos
      if params['_escaped_fragment_'] #this is google or facebook
        @photo = Photo.find(params['_escaped_fragment_'])
      end

      if params[:show_add_photos_dialog]
        if current_user
          if @album.contributor?(current_user.id)
            add_javascript_action('show_add_photos_dialog' )
          end
          redirect_to album_pretty_url(@album)
          return
        else
          redirect_to "#{join_url}?return_to=#{album_pretty_url(@album)}?show_add_photos_dialog=true"
          return
        end
      end

      render 'photos'
    end
  end

  # redirects to single picture view
  def show
    return unless require_album(true) && require_album_viewer_role
    photo = @album.photos.find(params[:photo_id])
    if(params[:show_comments])
      set_show_comments_cookie
    end
    redirect_to photo_pretty_url(photo)
  end

  # returns the  movie view
  # @album is set by before_filter require_album
  # you can pass sort options as in the photos_json
  # method to determine sort order which is passed
  # through and used to form the photos_json url via @sort_param
  def movie
    return unless require_album(true) && require_album_viewer_role
    @photos = @album.photos
    sort = params[:sort]

    # set up the sort param to be used in the movie view
    @sort_param = sort.nil? ? nil : "sort=#{sort}"

    render 'movie', :layout => false
  end


  def embedded_slideshow_js
    return unless require_album(true) && require_album_viewer_role
    render 'embedded_slideshow.js.erb', :layout => false
  end



  # store the json in compressed form if needed
  # returns compressed state, json
  def cache_photos_json(cache_key, json, gzip_compress)
    compressed = false
    begin
      #compress the content once before caching: save memory and save nginx from compressing every response
      json = checked_gzip_compress(json, 'album.cache.corruption', "Key: #{cache_key}, AlbumId: #{@album.id}, UserId: #{@album.user_id}") if gzip_compress
      compressed = gzip_compress
      CacheWrapper.write(cache_key, json, {:expires_in => 72.hours, :log => true})
    rescue Exception => ex
      # log the message but continue
      logger.error "Failed to cache: #{cache_key} due to #{ex.message}"
    end
    [compressed, json]
  end

  # request the photos for an album
  #
  def photos_json
    return unless require_album(true) && require_album_viewer_role
    photos_loader
  end

  # request the photos for an album
  #
  def zz_api_photos
    return unless require_album(true) && require_album_viewer_role
    zz_api_self_render do
      photos_loader
    end
  end

  # invalidate the current cached data for the photos in this album
  # we need this hack because we have seen corrupt json data being returned
  # from the cache so either issue with ruby,gzip, or memcached
  def photos_json_invalidate
    return unless require_album(true) && require_album_viewer_role
    Album.change_cache_version(@album.id)
    render :json => ''
  end


  # updates photo attributes
  # @photo is set in require_photo before filter
  def update
    return unless require_user && require_photo && require_album_admin_role
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
    return unless require_user && require_photo && require_album_admin_role
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
  def do_async_edit
    begin
      rotate_to = params[:rotate_to]
      crop = params[:crop]
      # queue up the rotate
      response_id = @photo.start_async_edit(:rotate_to => rotate_to, :crop => crop)
    rescue Exception => ex
      render_json_error(ex)
      return
    end
    render_async_response_json response_id
  end

  def async_edit
    return unless require_user && require_photo && require_photo_owner_or_album_admin_role
    do_async_edit
  end

  def async_rotate_left
    return unless require_user && require_photo && require_photo_owner_or_album_admin_role
    # passes control to async_rotate which does the proper requires

    rotate_to = @photo.rotate_to.to_i - 90
    if(rotate_to == -90)
      rotate_to = 270
    end

    params[:rotate_to] = rotate_to

    do_async_edit
  end


  def async_rotate_right
    return unless require_user && require_photo && require_photo_owner_or_album_admin_role
    # passes control to async_rotate which does the proper requires

    rotate_to = @photo.rotate_to.to_i + 90
    if(rotate_to == 360)
      rotate_to = 0
    end

    params[:rotate_to] = rotate_to

    do_async_edit
  end



  # @photo and @album are  set by require_photo before_filter
  def download
    return unless require_photo

    unless  @album.can_user_download?( current_user )
      flash.now[:error] = "Only Authorized Album Group Members can download photos"
      if request.xhr?
        head :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end

    if @photo && @photo.ready?
      type = @photo.safe_file_type
      filename = @photo.file_name_with_extension
      #url = @photo.original_url.split('?')[0]
      url = @photo.original_url
      zza.track_event("photos.download.original")
      Rails.logger.debug("Original download: #{ url}")

      if (browser.ie? && request.headers['User-Agent'].include?('NT 5.1'))
        # tricks to get IE to handle correctly
        # request.headers['Cache-Control'] = 'must-revalidate, post-check=0, pre-check=0'
        x_accel_redirect(url, :type=>type) and return
      else
        x_accel_redirect(url, :filename => filename, :type=>type) and return
      end
    else
      flash[:error]="Photo has not finished Uploading"
      head :not_found and return
    end
  end


  private

  # the low level code to create a batch of photos for agent_create or api
  # takes a hash in the form specified for the zz_api_create_photos call
  #
  def batch_photo_create(user_id, album_id, make_source_urls, args)
start_time = Time.now
    agent_id          = args[:agent_id]
    create_photos     = args[:photos]
    photo_count       = create_photos.length
    photos            = []
    # optimize by ensuring we have the number of ids we need up front
    current_id = Photo.get_next_id(photo_count)
    current_batch = UploadBatch.get_current_and_touch( user_id, album_id )
    batch_id = current_batch.id

    # now batch create all the photos
    create_photos.each do |create_photo|
      source_guid       = create_photo[:source_guid]
      raise ArgumentError.new("source_guid parameter required. Unable to create photos") if source_guid.nil?

      caption           = create_photo[:caption]
      file_size         = create_photo[:size]
      raise ArgumentError.new("size parameter required. Unable to create photos") if file_size.nil? || file_size == 0

      capture_date      = create_photo[:capture_date]
      capture_date = (Time.at(max_safe_epoch_time(Integer(capture_date))) rescue nil) unless capture_date.nil?

      source            = create_photo[:source]
      rotate_to         = create_photo[:rotate_to]    # optional initial rotation leave null to use rotation in file
      crop_to           = create_photo[:crop_to]      # optional initial cropping
      crop_json = crop_to ? JSON.fast_generate(crop_to) : nil

      photo = Photo.new_for_batch(current_batch,  {
                                    :id                =>   current_id,
                                    :album_id          =>   album_id,
                                    :user_id           =>   user_id,
                                    :upload_batch_id   =>   batch_id,
                                    :agent_id          =>   agent_id,
                                    :source_thumb_url  =>   make_source_urls ? Photo.make_agent_source('thumb', current_id, album_id) : nil,
                                    :source_screen_url =>   make_source_urls ? Photo.make_agent_source('screen', current_id, album_id) : nil,
                                    :source_guid       =>   source_guid,
                                    :source            =>   source,
                                    :rotate_to         =>   rotate_to,
                                    :crop_json         =>   crop_json,
                                    :caption           =>   caption ? caption : '',
                                    :image_file_size   =>   file_size,
                                    :capture_date      =>   capture_date
                                    }
                                    )
      current_id += 1
      photos << photo

      # log the input photo, helpful when we want to see args used to create a photo in loggly
      logger.debug create_photo.inspect
    end

    if (photos.count > 0)
      results = Photo.batch_insert(photos)
    end

end_time = Time.now
puts "Time in batch_photo_create with #{photo_count} photos: #{end_time - start_time}"

    photos
  end

  # define the acceptable types of sorts and the field order here
  def sort_fields_hash
    name_fields = [:caption, :capture_date, :created_at, :id]
    date_fields = [:capture_date, :created_at, :id]
    recent_fields = [:created_at, :id]
    sort_fields = {
        'name-asc' => name_fields,
        'name-desc' => name_fields,
        'date-asc' => date_fields,
        'date-desc' => date_fields,
        'recent-asc' => recent_fields,
        'recent-desc' => recent_fields,
    }
  end

  def sort_fields
    @@sort_fields ||= sort_fields_hash
  end

  def sort_fields_keys
    @@sort_fields_keys ||= sort_fields.keys
  end

  def validate_sort_param(sort)
    raise ArgumentError.new("Invalid sort type: #{sort}") unless sort_fields_keys.include?(sort)
  end

  def sort_photos(photos, sort_type)
    fields = sort_fields[sort_type]
    if fields
      # see if order should be reversed
      desc = !!sort_type.index('-desc')
      photos = sort_by_fields(photos, fields, desc, true)
    end
    photos
  end

  # given a json string with photos, parse it, sort it, and store it
  # returns compressed state and json
  def sort_and_cache_photos_json(cache_key, json, sort_type, gzip_compress)
    photos = JSON.parse(json)
    Hash.recursively_symbolize_graph!(photos)
    sorted_photos = sort_photos(photos, sort_type)
    json = JSON.fast_generate(sorted_photos)
    cache_photos_json(cache_key, json, gzip_compress)
  end

  # returns a json string of the album photos
  # @album is set by before_filter require_album
  #
  # you can also pass an optional sort param with
  # the values:
  # name-desc, name-asc - sorts on (caption, capture_date, creation_date, id)
  # date-desc, date-asc - sorts on (capture_date, creation_date, id)
  #
  def photos_loader
    gzip_compress = ZangZingConfig.config[:memcached_gzip]
    compressed = gzip_compress
    ver = params[:ver]

    cache_version_key = @album.cache_version_key || 0

    comp_flag = gzip_compress ? "Z1" : "Z0"
    # change the Photo.hash_schema_version method anytime you make a change
    # to the basic cache structure such as adding new
    # data to the returned info
    cache_key = "Album.Photos.#{comp_flag}.#{@album.id}.#{cache_version_key}"

    # if we have a sort key, try to fetch in sorted order directly from the cache first
    sort_type = params[:sort]
    if sort_type
      validate_sort_param(sort_type)
      sorted_key = "Album.Photos.#{comp_flag}.#{sort_type}.#{@album.id}.#{cache_version_key}"
      json = CacheWrapper.read(sorted_key, true)
      if json.nil?
        # no key with sorted order, try to get the unsorted set
        json = CacheWrapper.read(cache_key, true)
        if json
          # ok, we have a match so decompress, sort and store
          json = ActiveSupport::Gzip.decompress(json) if gzip_compress
          compressed, json = sort_and_cache_photos_json(sorted_key, json, sort_type, gzip_compress)
        else
          # not found in any form so pull them in from db in hashed form
          photos = Photo.hash_all_photos(@album.photos)
          # convert to json for unsorted form
          json = JSON.fast_generate(photos)
          # store unsorted form
          cache_photos_json(cache_key, json, gzip_compress)

          # now sort them and store
          sorted_photos = sort_photos(photos, sort_type)
          json = JSON.fast_generate(sorted_photos)
          compressed, json = cache_photos_json(sorted_key, json, gzip_compress)
        end
      end
    else
      # not sorted
      json = CacheWrapper.read(cache_key, true)
      if(json.nil?)
        # not found so pull from db and cache
        json = Photo.to_json_lite(@album.photos)
        compressed, json = cache_photos_json(cache_key, json, gzip_compress)
      end
    end
    render_cached_json(json, @album.public?, compressed)
  end

end
