class Connector::KodakPhotosController < Connector::KodakController


  def index
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    end
    photos_data = photos_list['pictures']
#    @photos = photos_data.map { |p| {:name => p['caption'], :id => p['id']} }

    @photos = photos_data.map { |p|
      {
        :name => p['caption'],
        :id   => p['id'],
        :type => 'photo',
        :thumb_url =>p[PHOTO_SIZES[:thumb]],
        :screen_url =>p[PHOTO_SIZES[:screen]],
        :add_url => kodak_photo_action_path({:kodak_album_id => params[:kodak_album_id], :photo_id => p['id'], :action => 'import'}),
        :source_guid => make_source_guid(p)

      }
    }
    #expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@photos)
    
  end

  def import
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    end
    photos_data = photos_list['pictures']
    p = photos_data.select { |p| p['id']==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]]
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :user_id=>current_user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :caption => p['caption'],
            :source_guid => make_source_guid(p),
            :source_thumb_url => p[PHOTO_SIZES[:thumb]],
            :source_screen_url => p[PHOTO_SIZES[:screen]]
    )
    
    ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
    render :json => Photo.to_json_lite(photo)
  end
end
