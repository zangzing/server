class Connector::InstagramPhotosController < Connector::InstagramController
  
  def self.list_photos(api, params)
    photo_list = call_with_error_adapter do
      api.user_recent_media(feed_owner(params), :min_timestamp => Time.at(0), :max_timestamp => Time.now, :count => 99999)
    end
    photo_list.reject! { |item| item[:type] != 'image' }
    photos = photo_list.map { |p|
      {
        :name => (p[:caption][:text] rescue ''),
        :id   => p[:id],
        :type => 'photo',
        :thumb_url => p[:images][:thumbnail][:url],
        :screen_url =>p[:images][:low_resolution][:url],
        :add_url => instagram_photo_action_path(params.merge(:photo_id => p[:id], :action => 'import')),
        :source_guid => make_source_guid(p)
      }
    }

    JSON.fast_generate(photos)
  end
  
  def self.import_photo(api, params)
    identity = params[:identity]
    photo_data = call_with_error_adapter do
      api.media_item(params[:photo_id])
    end
    current_batch = UploadBatch.get_current_and_touch(identity.user.id, params[:album_id])
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => (photo_data[:caption][:text] rescue ''),
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :work_priority => ZZ::Async::Priorities.import_single_photo,
            :capture_date => (Time.at(photo_data[:created_time].to_i) rescue nil),
            :source_guid => make_source_guid(photo_data),
            :source_thumb_url => photo_data[:images][:thumbnail][:url],
            :source_screen_url => photo_data[:images][:low_resolution][:url],
            :source => 'instagram'

    )

    queue_single_photo( photo, photo_data[:images][:standard_resolution][:url] )
    Photo.to_json_lite(photo)
  end
  
  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end

end
