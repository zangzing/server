class Connector::KodakFoldersController < Connector::KodakController

  def self.list_albums(api, params)
    album_list = api.send_request('/albumList')
    if album_list['Album']

      albums = [album_list['Album']].flatten.select { |a| a['type']=='0' } #Looks like real albums have type attribute = 0, but who knows...
      folders = albums.map { |f|
        {
          :name => f['name'],
          :type => "folder",
          :id  =>  f['id'],
          :open_url => kodak_photos_path(:kodak_album_id => f['id'], :format => 'json'),
          :add_url => kodak_folder_action_path(:kodak_album_id => f['id'], :action => 'import', :format => 'json')
        }
      }
    else
      folders = []
    end

    JSON.fast_generate(folders)
  end
  
  def self.import_album(api, params)
    identity = params[:identity]
    #photos_list = nil
    #SystemTimer.timeout_after(http_timeout) do
      photos_list = api.send_request("/album/#{params[:kodak_album_id]}")
    #end
    photos_data = photos_list['pictures']
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photos_data.each do |p|
      photo_url = p[PHOTO_SIZES[:full]]
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :user_id=>identity.user.id,
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
      ZZ::Async::KodakImport.enqueue( photo.id, photo.temp_url, api.auth_token )
    end

    Photo.to_json_lite(photos)
  end
  

  def index
    fire_async_response('list_albums')
    #render :json => self.class.list_albums(connector, params)
  end

  def import
    fire_async_response('import_album')
  end

end
