class Connector::KodakPhotosController < Connector::KodakController
  
  def self.list_photos(api, params)
    photos_list = call_with_error_adapter do
      api.send_request("/album/#{params[:kodak_album_id]}")
    end
    photos_data = photos_list['pictures']

    photos = photos_data.map { |p|
      {
        :name => p['caption'],
        :id   => p['id'],
        :type => 'photo',
        :thumb_url =>p[PHOTO_SIZES[:thumb]],
        :screen_url =>p[PHOTO_SIZES[:screen]],
        :add_url => kodak_photo_action_path(:kodak_album_id => params[:kodak_album_id], :photo_id => p['id'], :action => 'import'),
        :source_guid => make_source_guid(p)
      }
    }

    JSON.fast_generate(photos)
  end

  def self.import_photo(api, params)
    identity = params[:identity]

    photos_list = call_with_error_adapter do
      api.send_request("/album/#{params[:kodak_album_id]}")
    end

    photos_data = photos_list['pictures']
    p = photos_data.select { |p| p['id']==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]]
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :user_id => identity.user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :caption => p['caption'],
            :source_guid => make_source_guid(p),
            :source_thumb_url => p[PHOTO_SIZES[:thumb]],
            :source_screen_url => p[PHOTO_SIZES[:screen]],
            :source => 'kodak'

    )
    
    ZZ::Async::KodakImport.enqueue( photo.id, photo_url, api.auth_token )
    Photo.to_json_lite(photo)
  end


  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end
end
