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
    photos_data.each do |p|
      photo_url = p[PHOTO_SIZES[:full]].first
      photo = Photo.create(
              :caption => p['caption'].first,
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :source_guid => Photo.generate_source_guid(photo_url),
              :source_thumb_url => p[PHOTO_SIZES[:thumb]].first,
              :source_screen_url => p[PHOTO_SIZES[:screen]].first
      )
      
      Delayed::IoBoundJob.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))
      photos << photo
    end

    render :json => photos.to_json
  end

end
