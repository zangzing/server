class Connector::MobilemeFoldersController < Connector::MobilemeController

    def self.list_albums(api, params)
    album_list = call_with_error_adapter do
      api.get_albums_list
    end
    folders = []
    album_list.each do |album|
      album_id = album.path.match(/\d+$/)[0]
      folders << {
        :name => album.title,
        :type => 'folder',
        :id  => album_id,
        :open_url => mobileme_photos_path(:album_id => album_id, :action => :photos, :format => :json),
        :add_url  => mobileme_photos_path(:album_id => album_id, :action => :import_all, :format => :json)
      }
    end
    JSON.fast_generate(folders)
  end
  
  def self.list_photos(api, params)
    album_contents = call_with_error_adapter do
      api.get_album_contents(params[:album_id])
    end
    photos = []
    album_contents.each do |photo_data|
      next if photo_data.type=='Album'
      photo = {
        :name => photo_data.title,
        :id   => photo_data.guid,
        :type => 'photo',
        :thumb_url => get_photo_url(photo_data, :thumb),
        :screen_url => get_photo_url(photo_data, :screen),
        :add_url => mobileme_photos_path(:album_id => params[:album_id], :action => :import_photo, :photo_id =>  photo_data.guid, :format => :json),
        :source_guid => make_source_guid(photo_data)
      }
      photos << photo
    end
    JSON.fast_generate(photos)
  end  

  def self.import_dir_photos(api, params)
    identity = params[:identity]
    album_contents = call_with_error_adapter do
      api.open_album(params[:album_path])
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    (album_contents[:media] || []).each do |photo_data|
      photo_url = photo_data[:url]
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => photo_data[:title] || photo_data[:name],
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
              :source_guid => make_source_guid(photo_data[:url]),
              :source_thumb_url => photo_data[:thumb],
              :source_screen_url => photo_data[:thumb],
              :source => 'photobucket'
      })

      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end

  def self.import_certain_photo(api, params)
    identity = params[:identity]
    photo_data = call_with_error_adapter do
      api.call_method("/media/#{params[:photo_path]}")
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => photo_data[:title] || photo_data[:name],
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
            :source_guid => make_source_guid(photo_data[:url]),
            :source_thumb_url => photo_data[:thumb],
            :source_screen_url => photo_data[:thumb],
            :source => 'photobucket'

    )
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url] )

    Photo.to_json_lite(photo)
  end


  def index
    #fire_async_response('list_albums')
    render :json => self.class.list_albums(connector, params)
  end
  
  def photos
    render :json => self.class.list_photos(connector, params)
  end

  def import_photo
    fire_async_response('import_certain_photo')
  end

  def import_all
    fire_async_response('import_all_folders')
  end

end
