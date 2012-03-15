class Connector::SmugmugPhotosController < Connector::SmugmugController
  
  def self.list_photos(api, params)
    album_id, album_key = params[:sm_album_id].split('_')
    photos_response = call_with_error_adapter do
      api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    end
    photos = photos_response[:images].map { |p|
      {
        :name => (p[:caption].blank? ? p[:filename] : p[:caption]),
        :id   => "#{p[:id]}_#{p[:key]}",
        :type => 'photo',
        :thumb_url => '/service/proxy?url=' + p[:smallurl],
        :screen_url => '/service/proxy?url=' + p[:x3largeurl],
        :add_url => smugmug_photo_action_path(:sm_album_id =>album_id, :photo_id => "#{p[:id]}_#{p[:key]}", :action => 'import', :format => 'json'),
        :source_guid => make_source_guid(p)

      }
    }

    JSON.fast_generate(photos)
  end

  def self.import_photo(api, params)
    identity = params[:identity]
    photo_id, photo_key = params[:photo_id].split('_')
    photo_info = call_with_error_adapter do
      api.call_method('smugmug.images.getInfo', {:ImageID => photo_id, :ImageKey => photo_key})
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => (photo_info[:caption].blank? ? photo_info[:filename] : photo_info[:caption]),
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (DateTime.parse(photo_info[:lastupdated]) rescue nil),
            :work_priority => ZZ::Async::Priorities.import_single_photo,
            :source_guid => make_source_guid(photo_info),
            :source_thumb_url => '/service/proxy?url=' + photo_info[:smallurl],
            :source_screen_url => '/service/proxy?url=' + photo_info[:x3largeurl],
            :source => 'smugmug'


    )
    queue_single_photo( photo,  photo_info[:originalurl] )
    Photo.to_json_lite(photo)
  end

  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end

end
