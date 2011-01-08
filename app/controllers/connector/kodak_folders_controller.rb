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

    render :json => @folders.to_json
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
              :caption => p['caption'].first,
              :source_guid => make_source_guid(p),
              :source_thumb_url => p[PHOTO_SIZES[:thumb]].first,
              :source_screen_url => p[PHOTO_SIZES[:screen]].first
      )
      
    
      ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
      photos << photo
    end

    render :json => photos.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url, :original_url])
  end

end
