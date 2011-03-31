class Connector::SmugmugPhotosController < Connector::SmugmugController

  def index
    album_id, album_key = params[:sm_album_id].split('_')
    photos_response = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_response = smugmug_api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
  end
    @photos = photos_response[:images].map { |p|
      {
        :name => (p[:caption].blank? ? p[:filename] : p[:caption]),
        :id   => "#{p[:id]}_#{p[:key]}",
        :type => 'photo',
        :thumb_url => '/service/proxy?url=' + p[:smallurl],
        :screen_url => '/service/proxy?url=' + p[:x3largeurl],
        :add_url => smugmug_photo_action_url({:sm_album_id =>album_id, :photo_id => "#{p[:id]}_#{p[:key]}", :action => 'import'}),
        :source_guid => make_source_guid(p)
        
      }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@photos)
  end

  def import
    photo_id, photo_key = params[:photo_id].split('_')
    photo_info = nil
    SystemTimer.timeout_after(http_timeout) do
      photo_info = smugmug_api.call_method('smugmug.images.getInfo', {:ImageID => photo_id, :ImageKey => photo_key})
    end
    current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => (photo_info[:caption].blank? ? photo_info[:filename] : photo_info[:caption]),
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (DateTime.parse(photo_info[:lastupdated]) rescue nil),
            :source_guid => make_source_guid(photo_info),
            :source_thumb_url => '/service/proxy?url=' + photo_info[:smallurl],
            :source_screen_url => '/service/proxy?url=' + photo_info[:x3largeurl],
            :source => 'smugmug'


    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id,  photo_info[:originalurl] )
    render :json => Photo.to_json_lite(photo)

  end

end
