class Connector::ShutterflyPhotosController < Connector::ShutterflyController

  def self.photos_list(api_client, params)
    photos_list = call_with_error_adapter do
      api_client.get_images(params[:sf_album_id])
    end
    photos = photos_list.map { |p|
     {
        :name => p[:title],
        :id => p[:id],
        :type => 'photo',
        :thumb_url => get_photo_url(p[:id], :thumb),
        :screen_url => get_photo_url(p[:id], :screen),
        :add_url => shutterfly_photo_action_path(:sf_album_id =>params[:sf_album_id], :photo_id => p[:id], :action => 'import', :format => 'json'),
        :source_guid => make_source_guid(p)

     }
    }
    JSON.fast_generate(photos)
  end

  def self.import_photo(api_client, params)
    identity = params[:identity]
    photos_list = call_with_error_adapter do
      api_client.get_images(params[:sf_album_id])
    end
    photo_info = photos_list.select { |p| p[:id]==params[:photo_id] }.first
    photo_title = photo_info[:title]

    photo_url = get_photo_url(params[:photo_id],  :full)
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => photo_title,
            :album_id => params[:album_id],
            :user_id=>identity.user.id,
            :upload_batch_id => current_batch.id,
            :work_priority => ZZ::Async::Priorities.import_single_photo,
            :capture_date => photo_info[:capturetime].nil? ? nil : Time.at(photo_info[:capturetime].to_i/1000),
            :source_guid => make_source_guid(photo_info),
            :source_thumb_url => get_photo_url(params[:photo_id],  :thumb),
            :source_screen_url => get_photo_url(params[:photo_id],  :screen),
            :source => 'shutterfly'

    )

    queue_single_photo( photo, photo_url )
    json = Photo.to_json_lite(photo)
    return json
  end

  def index
    fire_async_response('photos_list')
  end

  def import
    fire_async_response('import_photo')
  end

end
