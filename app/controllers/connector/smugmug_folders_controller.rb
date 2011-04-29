class Connector::SmugmugFoldersController < Connector::SmugmugController
  
  def self.list_albums(api, params)
    album_list = call_with_error_adapter do
      api.call_method('smugmug.albums.get', :Extras => 'Passworded,PasswordHint,Password')
    end
    folders = album_list.map { |f|
      {
        :name => f[:title],
        :type => 'folder',
        :id  =>  "#{f[:id]}_#{f[:key]}",
        :open_url => smugmug_photos_path("#{f[:id]}_#{f[:key]}", :format => 'json'),
        :add_url => smugmug_folder_action_path(:sm_album_id =>"#{f[:id]}_#{f[:key]}", :action => 'import', :format => 'json')
      }
    }

    JSON.fast_generate(folders)    
  end

  def self.import_album(api, params)
    identity = params[:identity]
    album_id, album_key = params[:sm_album_id].split('_')
    photos_list = call_with_error_adapter do
      api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photos_list[:images].each do |p|
      photo_url = p[:originalurl]
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => (p[:caption].blank? ? p[:filename] : p[:caption]),
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (DateTime.parse(p[:lastupdated]) rescue nil),
              :source_guid => make_source_guid(p),
              :source_thumb_url => '/service/proxy?url=' + p[:smallurl],
              :source_screen_url => '/service/proxy?url=' + p[:x3largeurl],
              :source => 'smugmug'

      })

      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end

  def index
    fire_async_response('list_albums')
  end

  def import
    fire_async_response('import_album')
  end

end
