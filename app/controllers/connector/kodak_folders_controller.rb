class Connector::KodakFoldersController < Connector::KodakController

  def index
    album_list = connector.send_request('/albumList')
    albums = album_list['Album'].select { |a| a['type'].first=='0' } #Real albums have type attribute = 0
#    @folders = albums.map { |f| {:name => f['name'].first, :id => f['id'].first} }

    @folders = albums.map { |f|
      {
        :name => f['name'].first,
        :type => "folder",
        :id  =>  f['id'].first,
        :open_url => kodak_photos_path(f['id'].first),
        :add_url => kodak_folder_action_path({:kodak_album_id =>f['id'].first, :action => 'import'})
      }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@folders)
  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_data.each do |p|
      photo_url = p[PHOTO_SIZES[:full]].first
      photo = Photo.create(
              :user_id=>current_user.id,
              :album_id => params[:album_id],
              :upload_batch_id => current_batch.id,
              :capture_date => DateTime.now, #Absolutely no timestamps in data o_O
              :caption => p['caption'].first,
              :source_guid => make_source_guid(p),
              :source_thumb_url => p[PHOTO_SIZES[:thumb]].first,
              :source_screen_url => p[PHOTO_SIZES[:screen]].first
      )
      
    
      ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
      photos << photo
    end

    render :json => Photo.to_json_lite(photos)
  end

end
