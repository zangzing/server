class PhotosController < ApplicationController
  before_filter :oauth_required, :only => [:agentindex, :upload, :agent_create]
  before_filter :login_required, :only => [:create]
  before_filter :require_user, :only => [:show, :new, :edit, :destroy, :index]


  def show
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = CGI.escapeHTML(@album.name)
  end

  def new
    @album = Album.find(params[:album_id])
    @photo = Photo.new
    @title = 'New Photo'
  end

  def create
    @album = Album.find(params[:album_id])
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
    @album = Album.find(params[:album_id])
    @photos = []

    (0...params[:source_guid].length).each do |index|
      source_guid = params[:source_guid][index.to_s]
      size = params[:size][index.to_s]
      caption = params[:caption][index.to_s]

      @photo = @album.photos.build(:agent_id => params[:agent_id], :source_guid => source_guid, :caption => caption, :image_file_size => size)

      @photos << @photo

      @photo.user = current_user


      #todo: need to handle agent port and url templates in central place
      @photo.source_thumb_url = "http://localhost:9090/albums/#{@album.id}/photos/:photo_id.thumb"
      @photo.source_screen_url = "http://localhost:9090/albums/#{@album.id}/photos/:photo_id.screen"

      if @photo.save

      else
        render :json => photo.errors, :status=>500
        return
      end
    end

    render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :source_thumb_url, :source_screen_url, :source_guid], :methods => [:thumb_url, :medium_url])
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


  def upload
    begin
      @photo = Photo.find(params[:id])
      @album = @photo.album
      if @photo.update_attributes(params[:photo])
        render :json => @photo.to_json(:only =>[:id, :agent_id, :state])
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
  #
  # upload_batch Display only album photos in given upload_batch
  #              upload_batch must belong to album
  def index
    @album = Album.find(params[:album_id])
    @title = CGI.escapeHTML(@album.name)
    @user=  @album.user
    @badge_name = @user.name
    UploadBatch.close_open_batches( current_user, @album) if signed_in?

    if params[:upload_batch] && @upload_batch = UploadBatch.find(params[:upload_batch])
      @all_photos = @upload_batch.photos
    else
      @all_photos = @album.photos
    end

    respond_to do |format|
      format.html do
        if !params[:size].nil? && params[:size] == 'screenres'
          @photos = @all_photos.paginate({:page =>params[:page], :per_page => 1})
          unless  params[:photoid].nil?
            current_page = 1 if params[:page].nil?
            until @photos[0][:id] == params[:photoid]
              current_page += 1
              @photos = @all_photos.paginate({:page =>current_page, :per_page => 1})
            end
            params[:photoid] = nil
          end
          render 'slideshow'
        else
          @photo = Photo.new
          @photos = @all_photos
          render 'grid'
        end
      end

      format.json do
        render :json => @all_photos.to_json(:methods => [:thumb_url, :medium_url])
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
  #
  def edit
    @album = Album.find(params[:album_id])
    @title = CGI.escapeHTML(@album.name)
    @user=  @album.user

    respond_to do |format|
      format.html do
        if !params[:size].nil? && params[:size] == 'screenres'
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
        render :json => @album.photos.to_json(:methods => [:thumb_url, :medium_url])
      end
    end
  end


end
