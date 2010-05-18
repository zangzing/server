class PhotosController < ApplicationController

  def create
      logger.debug "The params hash in PhotosController create is #{params.inspect}"
      @album = Album.find( params[:album_id] )
      @photo = @album.photos.build( params[:photo])
      if !@photo.save
          flash[:error] = "Unable to add Photo!"
      end
      redirect_to  @album
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