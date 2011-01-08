class Connector::FlickrFoldersController < Connector::FlickrController



  def index
    folders_response = flickr_api.photosets.getList

    @folders = folders_response.map { |f|
      {
        :name => f.title,
        :type => "folder",
        :id  =>  f.id,
        :open_url => flickr_photos_url(f.id),
        :add_url => flickr_folder_action_url({:set_id =>f.id, :action => 'import'})
      }
    }
    render :json => @folders.to_json

  end
  
  def import
    photo_set = flickr_api.photosets.getPhotos :photoset_id => params[:set_id], :extras => 'original_format'
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo_set.photo.each do |p|
      #todo: refactor this so that flickr_folders_controller and flickr_photos_controller can share
      photo_url = get_photo_url(p, :full)
      photo = Photo.create(
                :user_id=>current_user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :caption => p.title,
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen)
      )

      
      ZZ::Async::GeneralImport.enqueue( photo.id, photo_url )
      photos << photo
    end

    render :json => photos.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url, :original_url])
  end
end
