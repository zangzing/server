require "zz_env_helpers"

class PhotosController < ApplicationController
  # filters for agent actions
  before_filter :oauth_required,                 :only => [:agentindex, :agent_create]
  skip_before_filter :verify_authenticity_token, :only => [:agentindex, :agent_create, :upload_fast]


  before_filter :require_user, :only => [:create, :update, :destroy ] #TODO Sort out album security so facebook can freely dig into album page



  #before_filter :determine_album_user #For friendly_id's scope

  def create
    @album = fetch_album
    @photo = @album.photos.build(params[:photo])
    @photo.user = current_user

    respond_to do |format|
      format.html do
        if @photo.save
          flash[:success] = "Photo Created!"
          render :action => :show
        else
          render :action => :new
        end
      end
      format.json do
        if @photo.save
          render :json => @photo.to_json(:only =>[:id, :agent_id, :state])
        else
          render :json => @photo.errors, :status=>500
        end
      end
    end
  end


  def agent_create
    if params[:source_guid].nil?
      render :json => "source_guid parameter required. Unable to create photos", :status=>400 and return
    end

    album             = fetch_album
    user_id           = current_user.id

    # validate that current_user is a contributor
    # (the agent has a token for a user that here is known as current_user)
    #todo: generalize with before filter
    render :json => "User does not have permission to add photos to this album",
           :status=> 401 and return unless album.contributor?( user_id )
      

    album_id          = album.id
    agent_id          = params[:agent_id]
    photos            = []
    source_guid_map   = params[:source_guid]
    photo_count       = source_guid_map.length
    caption_map       = params[:caption]
    file_size_map     = params[:size]
    capture_date_map  = params[:capture_date]
    source_map        = params[:source]

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
                                    :caption           =>   safe_hash_default(caption_map, i_s, ""),
                                    :image_file_size   =>   file_size_map[i_s],
                                    :capture_date      =>   Time.at( safe_hash_default(capture_date_map, i_s, 0).to_i )
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

    render :json => Photo.to_json_lite(photos)
  end


  def agentindex
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
        #give the agent a chance to retry
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

  def destroy
    @photo = Photo.find(params[:id])

    unless current_user?( @photo.user )
      render :json => 'Only photo owner can delete photos', :status => 401 and return
    end
    
    @album = @photo.album
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
    fetch_album

    #Verify if user has viewer permissions otherwise ask them to sign in
    if @album.private?
        unless current_user
          store_location
          flash[:notice] = "You have asked to see a password protected album. Please login so we know who you are."
          redirect_to new_user_session_url and return
        end
        unless @album.viewer?( current_user.id )
          session[:client_dialog] = album_pwd_dialog_url( @album )
          redirect_to user_url( @album.user ) and return
        end
    end
    
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

  def movie
    @album = fetch_album
    @photos = @album.photos
    render 'movie', :layout => false
  end

  def photos_json
    @album = fetch_album

    if stale?(:last_modified => @album.photos_last_updated_at.utc, :etag => @album)

      cache_key = "Album.Photos." + @album.id.to_s + '-' + @album.photos_last_updated_at.to_i.to_s + '.json'

      logger.debug 'cache key: ' + cache_key

      json = Rails.cache.read(cache_key)

      if(json.nil?)
        json = Photo.to_json_lite(@album.photos)

        #compress the content once before caching: save memory and save nginx from compressing every response
        json = ActiveSupport::Gzip.compress(json)

        Rails.cache.write(cache_key, json)
        logger.debug 'caching photos_json'
      else
        logger.debug 'using cached photos_json'
      end

      expires_in 1.year, :public => true  #todo: make private for password protected albums
      response.headers['Content-Encoding'] = "gzip"
      render :json => json
    else
      logger.debug 'etag match, sending 304'
    end
  end

  def profile
     @album = Album.find( params[:album_id])
     current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
     @photo = @album.photos.build(:agent_id => "PROFILE_PHOTO",
                                  :source_guid => "PROFILE_FORM",
                                  :caption => "LUCKY ME",
                                  :upload_batch_id => current_batch.id,
                                  :image_file_size => 128)
      @photo.user = current_user
      @photo.save
      render :layout =>false
  end

  def update
    @photo = Photo.find(params[:id])

    if @photo && @photo.update_attributes( params[:photo] )
      flash[:notice] = "Photo Updated!"
      render :text => 'Success Updating Photo', :status => 200, :layout => false
    else
      errors_to_headers( @photo )
      render :text => 'Photo update did not succeed', :status => 500, :layout => false
    end
  end

  #used by the photogrid to notify changes in the album order when a photo is dragged and dropped
  # expects :before_id and :after_id
  def position
    #begin
      photo = Photo.find( params[:id] )
      photo.position_between( params[:before_id], params[:after_id])
    #rescue Exception => e
    #  render :json => e.message, :status => 500 and return
    #end
    render :text => "Position Done!", :status => 200
  end

  
private

  def fetch_album
    if params[:user_id]
      @album = Album.find(params[:album_id], :scope => params[:user_id])
    else
      @album = Album.find( params[:album_id] )
    end
  end

  #def determine_album_user
  #  @album_user_id = params[:user_id] #|| current_user.to_param
  #end

end
