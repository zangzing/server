class PhotosController < ApplicationController

  def create
      logger.debug "The params hash i n PhotosController create is #{params.inspect}"
      @album = Album.find( params[:album_id] )
      @photo = @album.photos.build( params[:photo])
      @album.errors.each{|attr,msg| logger.debug "#{attr} - #{msg}" }

      respond_to do |format|
        format.html{
             if @photo.save
                  flash[:success] = "Photo Added!"
             end
             @user = @album.user
             @photos = @album.photos.paginate(:page =>params[:page])
             @photo  = Photo.new
             render  'albums/show'

        }
        format.xml{
             if @photo.save
              render :xml => @photo.to_xml
             else
              #response = '<?xml version="1.0" encoding="UTF-8"?><errors>'
              #@photo.errors.each {|attr,msg|
              #  response += '<error>'
              #  response += '<attribute>'+ attr +'</attribute>'
              #  response += '<message>'+msg +'</message>'
              # response += '</error>'
              #}
              #response += '</errors>'
              render :xml => '<?xml version="1.0" encoding="UTF-8"?>'+ @photo.errors.to_xml , :status=>500
            end
        }
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