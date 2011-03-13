require "zz_env_helpers"

class PhotosController < ApplicationController
  before_filter :oauth_required, :only => [:agentindex, :agent_create]
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

    album = fetch_album
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, album.id )
    (0...params[:source_guid].length).each do |index|
      photo = album.photos.build(   :user_id           =>   current_user.id,
                                    :upload_batch_id   =>   current_batch.id,
                                    :agent_id          =>   params[:agent_id],
                                    :source_guid       =>   params[:source_guid][index.to_s],
                                    :caption           =>   params[:caption][index.to_s],
                                    :image_file_size   =>   params[:size][index.to_s],
                                    :capture_date      =>   Time.at( params[:capture_date][index.to_s].to_i ))
                                    #todo: need to handle agent port and url templates in central place for source thumb_url and screen_url
      if photo.save
         photos << photo
      else
        render :json => photo.errors, :status=>500 and return
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
       #hack: need to do this better
       #force redirect back to /username/albumname/photos
      redirect_to "/#{@album.user.username}/#{@album.friendly_id}/photos"
    else
      @title = CGI.escapeHTML(@album.name)
      @photos = @album.photos
      if params['_escaped_fragment_']
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
     current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
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
