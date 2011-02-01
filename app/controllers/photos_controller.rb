class PhotosController < ApplicationController
  before_filter :oauth_required, :only => [:agentindex, :agent_create]
  before_filter :login_required, :only => [:create ]
  before_filter :require_user, :only => [:show, :new, :edit, :destroy, :update] # , :index] #TODO Sort out album security so facebook can freely dig into album page
  before_filter :determine_album_user #For friendly_id's scope

  def show
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = CGI.escapeHTML(@album.name)
  end

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
      photo = album.photos.build(   :user_id =>           current_user.id,
                                    :upload_batch_id =>   current_batch.id,
                                    :agent_id =>          params[:agent_id],
                                    :source_guid =>       params[:source_guid][index.to_s],
                                    :caption =>           params[:caption][index.to_s],
                                    :image_file_size =>   params[:size][index.to_s],
                                    :source_thumb_url =>  "http://localhost:30777/albums/#{album.id}/photos/:photo_id.thumb",
                                    :source_screen_url => "http://localhost:30777/albums/#{album.id}/photos/:photo_id.screen")
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
      rescue ActiveRecord::RecordNotFound => ex
        #photo or album have been deleted
        render :json => ex.to_s, :status=>400

      rescue ActiveRecord::StatementInvalid => ex
        #this seems to mean connection issue with database
        render :json => ex.to_s, :status=>500

      rescue Exception => ex
        #todo: make sure none of these should be 4xx errors
        render :json => ex.to_s, :status=>500
      end
    else
      # call did not come through remapped upload via nginx so reject it
      render :json => "Invalid upload_fast arguments.", :status=>400
    end
  end

  def destroy
    logger.debug "The params hash in PhotosController destroy is #{params.inspect}"
    @photo = Photo.find(params[:id])
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

  #
  # Shows all photos for a given album
  #
  # Photos can be shown in a slideshow or a grid based on the query arguments
  #
  # size         thumb|screeenres  Show all thumbnails or 1 screenres.
  #              Default: show all thumbs
  # photoid      Id of photo that should be displayed when in screenres
  #              Default: Show first pic in album
  # page         Page desired when in screenres                         
  #              Default: First
  # upload_batch Display only album photos in given upload_batch
  #              upload_batch must belong to album
  # contributor  Display only photos contributed by certain contributor.
  #              contributor must be in albums contributor list

  def index
    @album = fetch_album

    respond_to do |format|
      format.html do


        @title = CGI.escapeHTML(@album.name)

        if params[:upload_batch] && @upload_batch = UploadBatch.find(params[:upload_batch])
          @all_photos = @upload_batch.photos
          @return_to_link = "#{album_activities_path( @album )}##{@upload_batch.id}"
        elsif params[:contributor] && @contributor = Contributor.find(params[:contributor])
          @all_photos = @contributor.photos
          @return_to_link = "#{album_people_path( @album )}##{@contributor.id}"
        else
          @all_photos = @album.photos
          @return_to_link = album_photos_url( @album.id )
        end



#        if !params[:view].nil? && params[:view] == 'slideshow'
#          @photos = @all_photos.paginate({:page =>params[:page], :per_page => 1})
#          unless  params[:photoid].nil?
#            current_page = 1 if params[:page].nil?
#            until @photos[0][:id] == params[:photoid]
#              current_page += 1
#              @photos = @all_photos.paginate({:page =>current_page, :per_page => 1})
#            end
#            params[:photoid] = nil
#          end
#          render 'slideshow'

        if !params[:view].nil? && params[:view] == 'movie'
          @photos = @all_photos
          render 'movie', :layout => false
        else
          @photo = Photo.new
          @photos = @all_photos
          render 'photos'
        end
      end
    end
  end

  def photos_json
    @album = fetch_album

    if stale?(:last_modified => @album.photos_last_updated_at.utc, :etag => @album)

      cache_key = "Album.Photos." + @album.id + '-' + @album.photos_last_updated_at.to_i.to_s + '.json'
      cache_key = cache_key.gsub(' ', '_')

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

      response.headers["Cache-Control"] = 'max-age=31536000' #todo: make private for password protected albums
      response.headers["Expires"] = CGI.rfc1123_date(Time.now + 1.year)
      response.headers['Content-Encoding'] = "gzip"
      render :json => json
    else
      logger.debug 'etag match, sending 304'
    end
  end


#  def slideshowbox_source
#    @album = fetch_album
#    @photos = @album.photos
#    respond_to do |format|
#      format.xml
#    end
#  end


#
  # Shows all photos for a given album
  #
  # Photos can be shown in a slideshow or a grid based on the query arguments
  #
  # size         thumb|screeenres  Show all thumbnails or 1 screenres.
  #              Default: show all thumbs
  # photoid      Id of photo that should be displayed when in screenres
  #              Default: Show first pic in album
  # page         Page desired when in screenres
  #              Default: First
  #
  def edit
    @album = fetch_album
    @title = CGI.escapeHTML(@album.name)

    respond_to do |format|
      format.html do
        if !params[:view].nil? && params[:view] == 'slideshow'
          @photos = @album.photos.paginate({:page =>params[:page], :per_page => 1})
          unless  params[:photoid].nil?
            current_page = 1 if params[:page].nil?
            until @photos[0][:id] == params[:photoid]
              current_page += 1
              @photos = @album.photos.paginate({:page =>current_page, :per_page => 1})
            end
            params[:photoid] = nil
          end
          render 'slideshow'
        else
          @photo = Photo.new
          @photos = @album.photos
          render 'grid'
        end
      end

      format.json do
        render :json => @album.photos.to_json(:methods => [:thumb_url, :screen_url])
      end
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


private

  def fetch_album
    params[:friendly] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.first(:conditions => {:id => params[:album_id]})
  end

  def determine_album_user
    @album_user_id = params[:user_id] #|| current_user.to_param
  end

end
