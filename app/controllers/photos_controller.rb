class PhotosController < ApplicationController
  before_filter :oauth_required, :only => [:agentindex, :upload, :agent_create]
  before_filter :login_required, :only => [:create]
  before_filter :require_user, :only => [:show, :new, :edit, :destroy, :index]


  def show
    logger.debug "The params hash i n PhotosController show is #{params.inspect}"
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = CGI.escapeHTML(@album.name)
  end

  def new
    @album = Album.find(params[:album_id])
    @photo = Photo.new
    @title = 'New Photo'
  end


#  def create_multiple
#    @album = Album.find( params[:album_id] )
#
#    count = params[:count]
#    @photos = []
#
#    count.to_i.times do
#      photo = @album.photos.build( params[:photo])
#      photo.save
#      @photos << photo
#    end
#
#    render :json => @photos.to_json(:only =>[:id, :agent_id, :state])
#
#  end

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

    params['source_guid'].values.each do |source_guid|

      @photo = @album.photos.build(:agent_id => params[:agent_id], :source_guid => source_guid)

      @photos << @photo

      @photo.user = current_user


      if @photo.save
        #todo: need to handle agent port and url templates in central place
        @photo.source_thumb_url = "http://localhost:9090/albums/#{@album.id}/photos/#{@photo.id}.thumb"
        @photo.source_screen_url = "http://localhost:9090/albums/#{@album.id}/photos/#{@photo.id}.screen"

        if @photo.save

        else
          render :json => photo.errors, :status=>500
          return
        end
      else
        render :json => photo.errors, :status=>500
        return
      end
    end

    render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :source_thumb_url, :source_screen_url, :source_guid], :methods => [:thumb_url, :medium_url])
  end

  def edit
    @photo = Photo.find(params[:id])
    @album = @photo.album Person.find
    @title = "Update Photo"
  end

  def upload
    @photo = Photo.find(params[:id])
    @album = @photo.album
    respond_to do |format|
      format.html do
        if @photo.update_attributes(params[:photo])
          flash[:success] = "Photo Uploaded!"
          render :action => :show
        else
          render :action => :index
        end
      end
      format.json do
        if @photo.update_attributes(params[:photo])
          render :json => @photo.to_json(:only =>[:id, :agent_id, :state])
        else
          render :json => @photo.errors, :status=>500
        end
      end
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
  def index
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
        render :json => @album.photos.to_json( :methods => [:thumb_url, :medium_url])
      end
    end
  end

  def agentindex
    @photos = Photo.all(:conditions => ["agent_id = ? AND state = ?", params[:agent_id], 'assigned'])
    respond_to do |format|
      format.html do
        render @photos
      end
      format.json do
        render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :album_id])

      end
    end
  end


end
