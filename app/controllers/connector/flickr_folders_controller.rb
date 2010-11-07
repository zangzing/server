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
    photo_set.photo.each do |p|

      #todo: refactor this so that flickr_folders_controller and flickr_photos_controller can share
      photo_url = get_photo_url(p, :full)
      photo = Photo.create(
                :caption => p.title,
                :album_id => params[:album_id],
                :user_id=>current_user.id,
                :source_guid => Photo.generate_source_guid(photo_url),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen)
      )

      
      ZZ::Async::GeneralImport.enqueue( photo.id, photo_url )
      photos << photo
    end

    render :json => photos.to_json
  end
end
