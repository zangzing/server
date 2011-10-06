class Connector::KodakFoldersController < Connector::KodakController

  def self.list_albums(api, params)
    album_list = call_with_error_adapter do
      api.send_request('/albumList')
    end
    if album_list && album_list['Album']

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
    photos_list = call_with_error_adapter do
      api.send_request("/album/#{params[:kodak_album_id]}")
    end
    photos_data = photos_list['pictures'] || []
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
      kodak_albums = [album_list['Album']].flatten.select { |a| a['type']=='0' } #Looks like real albums have type attribute = 0, but who knows...

      kodak_albums.each do |k_album|
        zz_album = create_album(identity, k_album['name'])
        photos = import_album(api, params.merge(:album_id => zz_album.id, :kodak_album_id => k_album['id']))
        zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id, :photos => photos}
      end
    end
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
