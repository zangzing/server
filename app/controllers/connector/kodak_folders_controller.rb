class Connector::KodakFoldersController < Connector::KodakController

  def self.list_albums(api, params)
    folders = []
    #Regular albums
    album_list = call_with_error_adapter do
      api.send_request('/albumList')
    end
    if album_list && album_list['Album']
      albums = [album_list['Album']].flatten.select { |a| a['type']=='0' } #Looks like real albums have type attribute = 0, but who knows...
      albums.each { |f|
        folders << {
          :name => f['name'],
          :type => "folder",
          :id  =>  f['id'],
          :open_url => kodak_photos_path(:kodak_album_id => f['id'], :format => 'json'),
          :add_url => kodak_folder_action_path(:kodak_album_id => f['id'], :action => 'import', :format => 'json')
        }
      }
    end
    #Group albums
    album_list = call_with_error_adapter do
      api.send_request("/user/#{api.user_ssid}/eventAlbumList")
    end
    if album_list && album_list['EventAlbum']
      albums = [album_list['EventAlbum']].flatten
      albums.each do |ga|
        folders << {
          :name => ga['Album']['name'],
          :type => "folder",
          :id  =>  ga['Album']['id'],
          :open_url => kodak_photos_path(:kodak_album_id => ga['Album']['id'], :group_id => ga['Group']['id'], :format => 'json'),
          :add_url => kodak_folder_action_path(:kodak_album_id => ga['Album']['id'], :group_id => ga['Group']['id'], :action => 'import', :format => 'json')
        }
      end
    end

    JSON.fast_generate(folders)
  end
  
  def self.import_album(api, params)
    identity = params[:identity]
    photos_list = call_with_error_adapter do
      if params[:group_id]
        api.send_request("/group/#{params[:group_id]}/album/#{params[:kodak_album_id]}")
      else
        api.send_request("/album/#{params[:kodak_album_id]}")
      end
    end
    photos_data = photos_list['pictures'] || []
    photos_data = [photos_data] if photos_data.is_a?(Hash)

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
      ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url, :headers => api.compose_request_header )
    end

    Photo.to_json_lite(photos)
  end

  def self.import_all_albums(api, params)
    identity = params[:identity]
    zz_albums = []
    album_list = call_with_error_adapter do
      api.send_request('/albumList')
    end
    if album_list && album_list['Album']
      regular_albums = [album_list['Album']].flatten.select { |a| a['type']=='0' } #Looks like real albums have type attribute = 0, but who knows...

      regular_albums.each do |k_album|
        zz_album = create_album(identity, k_album['name'], params[:privacy])
        zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id}
        fire_async('import_album', params.merge(:album_id => zz_album.id, :kodak_album_id => k_album['id']))
      end
    end
    album_list = call_with_error_adapter do
      api.send_request("/user/#{api.user_ssid}/eventAlbumList")
    end
    if album_list && album_list['EventAlbum']
      group_albums = [album_list['EventAlbum']].flatten
      group_albums.each do |k_album|
        zz_album = create_album(identity, k_album['Album']['name'], params[:privacy])
        zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id}
        fire_async('import_album', params.merge(:album_id => zz_album.id, :kodak_album_id => k_album['Album']['id'], :group_id => k_album['Group']['id']))
      end
    end

    identity.last_import_all = Time.now
    identity.save


    JSON.fast_generate(zz_albums)
  end


  def index
    fire_async_response('list_albums')
    #render :json => self.class.list_albums(connector, params)
  end

  def import
    fire_async_response('import_album')
  end

  def import_all
    fire_async_response('import_all_albums')
  end


end
