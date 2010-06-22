class PhotosController < ApplicationController

  def show
    logger.debug "The params hash i n PhotosController show is #{params.inspect}"
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = CGI.escapeHTML(@album.name)
  end
 
  def new
      @album = Album.find( params[:album_id] )
      @photo = Photo.new
      @title = 'New Photo'
  end

  def create
    logger.debug "The params hash i n PhotosController create is #{params.inspect}"
    @album = Album.find( params[:album_id] )
    @photo = @album.photos.build( params[:photo])
    respond_to do | format |
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

  def edit
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = "Update Photo"
  end

  def upload
      logger.debug "The params hash i n PhotosController update is #{params.inspect}"
      @photo = Photo.find(params[:id])
      @album = @photo.album
      respond_to do |format|
        format.html do
          if @photo.update_attributes(params[:photo])
            flash[:success] = "Photo Updated!"
            render :action => :show
          else
            render :action => :edit
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
    if !@photo.destroy
          flash[:error] = "Unable to delete photo!"
    end
    redirect_to @album
  end
end