class Connector::KodakFoldersController < Connector::KodakController

  def index
    album_list = nil
    SystemTimer.timeout_after(http_timeout) do
      album_list = connector.send_request('/albumList')
    end
    albums = [album_list['Album']].flatten.select { |a| a['type']=='0' } #Looks like real albums have type attribute = 0, but who knows...
    @folders = albums.map { |f|
      {
        :name => f['name'],
        :type => "folder",
        :id  =>  f['id'],
        :open_url => kodak_photos_path(f['id']),
        :add_url => kodak_folder_action_path({:kodak_album_id =>f['id'], :action => 'import'})
      }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@folders)
  end

  def import
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    end
    photos_data = photos_list['pictures']
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_data.each_with_index do |p, idx|
      photo_url = p[PHOTO_SIZES[:full]]
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :user_id=>current_user.id,
              :album_id => params[:album_id],
              :upload_batch_id => current_batch.id,
              :caption => p['caption'],
              :source_guid => make_source_guid(p),
              :source_thumb_url => p[PHOTO_SIZES[:thumb]],
              :source_screen_url => p[PHOTO_SIZES[:screen]],
              :source => 'kodak'

      })
    
      photo.temp_url = photo_url
      photos << photo

    end

    # bulk insert
    Photo.batch_insert(photos)

    # must send after all saved
    photos.each do |photo|
      ZZ::Async::KodakImport.enqueue( photo.id, photo.temp_url, connector.auth_token )
    end

    render :json => Photo.to_json_lite(photos)
  end

end
