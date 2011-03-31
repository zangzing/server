class Connector::FlickrFoldersController < Connector::FlickrController



  def index
    folders_response = []
    SystemTimer.timeout_after(http_timeout) do
      folders_response = flickr_api.photosets.getList
    end
    @folders = folders_response.map { |f|
      {
        :name => f.title,
        :type => "folder",
        :id  =>  f.id,
        :open_url => flickr_photos_url(f.id),
        :add_url => flickr_folder_action_url({:set_id =>f.id, :action => 'import'})
      }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@folders)
  end
  
  def import
    photo_set = []
    SystemTimer.timeout_after(http_timeout) do
      photo_set = flickr_api.photosets.getPhotos :photoset_id => params[:set_id], :extras => 'original_format,date_taken'
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
    photo_set.photo.each do |p|
      #todo: refactor this so that flickr_folders_controller and flickr_photos_controller can share
      photo_url = get_photo_url(p, :full)
      photo = Photo.new_for_batch(current_batch, {
                :id => Photo.get_next_id,
                :user_id=>current_user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :capture_date => (DateTime.parse(p.datetaken) rescue nil),
                :caption => p.title,
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen),
                :source => 'flickr'

      })

      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end
end
