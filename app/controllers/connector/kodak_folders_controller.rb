class Connector::KodakFoldersController < Connector::KodakController

  def index
    album_list = connector.send_request('/albumList')
    albums = album_list['Album'].select { |a| a['type']=='0' } #Real albums have type attribute = 0
#    @folders = albums.map { |f| {:name => f['name'], :id => f['id']} }

    @folders = albums.map { |f|
      {
        :name => f['name'],
        :type => "folder",
        :id  =>  f['id'],
        :open_url => kodak_photos_path(f['id']),
        :add_url => kodak_folder_action_path({:kodak_album_id =>f['id'], :action => 'import'})
      }
    }
    #expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@folders)
  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_data.each_with_index do |p, idx|
      photo_url = p[PHOTO_SIZES[:full]]
      photo = Photo.create(
              :user_id=>current_user.id,
              :album_id => params[:album_id],
              :upload_batch_id => current_batch.id,
              :caption => p['caption'],
              :source_guid => make_source_guid(p),
              :source_thumb_url => p[PHOTO_SIZES[:thumb]],
              :source_screen_url => p[PHOTO_SIZES[:screen]]
      )
    
      ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
      photos << photo
    end

    render :json => Photo.to_json_lite(photos)
  end

end
