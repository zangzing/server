class Connector::MobilemeFoldersController < Connector::MobilemeController

  PWD_PROTECTED_STATIC_ICON = '/images/password-protected-view-after-import.png'

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
        :open_url => mobileme_photos_path(:mm_album_id => album_id, :action => :photos, :format => :json),
        :add_url  => mobileme_photos_path(:mm_album_id => album_id, :action => :import_all, :format => :json)
      }
    end
    JSON.fast_generate(folders)
  end
  
  def self.list_photos(api, params)
    album_contents = call_with_error_adapter do
      api.get_album_contents(params[:mm_album_id])
    end
    photos = []
    album_contents.each do |photo_data|
      next if photo_data['type']=='Album'
      photo = {
        :name => photo_data.title,
        :id   => photo_data.guid,
        :type => 'photo',
        :thumb_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :thumb),
        :screen_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :screen),
        :add_url => mobileme_photos_path(:mm_album_id => params[:mm_album_id], :action => :import_photo, :photo_id => photo_data.guid, :format => :json),
        :source_guid => make_source_guid(photo_data)
      }
      photos << photo
    end
    JSON.fast_generate(photos)
  end  

  def self.import_dir_photos(api, params)
    identity = params[:identity]
    album_contents = call_with_error_adapter do
      api.get_album_contents(params[:mm_album_id])
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    album_contents.each do |photo_data|
      next if photo_data['type']=='Album'
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => photo_data.title,
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (DateTime.parse(photo_data.photoDate) rescue nil),
              :source_guid => make_source_guid(photo_data),
              :source_thumb_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :thumb),
              :source_screen_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :screen),
              :source => 'mobileme'
      })

      photo.temp_url = get_photo_url(photo_data, :full)
      photos << photo
    end

    # bulk insert
    Photo.batch_insert(photos)

    # must send after all saved
    photos.each do |photo|
      ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url, :headers => {'Cookie' => api.cookies_as_string})
    end

    Photo.to_json_lite(photos)
  end

  def self.import_certain_photo(api, params)
    identity = params[:identity]
    album_contents = call_with_error_adapter do
      api.get_album_contents(params[:mm_album_id])
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo_data = album_contents.select{|p| p.guid==params[:photo_id] }.first
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => photo_data.title,
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (DateTime.parse(photo_data.photoDate) rescue nil),
            :source_guid => make_source_guid(photo_data),
            :source_thumb_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :thumb),
            :source_screen_url => password_protected?(album_contents) ? PWD_PROTECTED_STATIC_ICON : get_photo_url(photo_data, :screen),
            :source => 'mobileme'
    )

    ZZ::Async::GeneralImport.enqueue( photo.id, get_photo_url(photo_data, :full), :headers => {'Cookie' => api.cookies_as_string} )

    Photo.to_json_lite(photo)
  end

  def self.password_protected?(album_contents)
    album_contents.select{|e| e['type']=='Album' }.first.has_key?('accessLogin')
  end


  def index
    fire_async_response('list_albums')
  end
  
  def photos
    fire_async_response('list_photos')
  end

  def import_photo
    fire_async_response('import_certain_photo')
  end

  def import_all
    fire_async_response('import_dir_photos')
  end

end
