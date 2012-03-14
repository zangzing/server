class Connector::FacebookPhotosController < Connector::FacebookController

  def self.list_photos(api_client, params)
    photos_response = call_with_error_adapter do
      api_client.get("#{params[:fb_album_id]}/photos", :limit => 1000)
    end

    unless photos_response.empty?
      if photos_response.first[:updated_time]
        photos_response.sort!{|a, b| b[:updated_time] <=> a[:updated_time] }
      end
      @photos = photos_response.map do |p|
        {
          :name => p[:name] || '',
          :id   => p[:id],
          :type => 'photo',
          :thumb_url =>get_photo_url(p, :thumb),
          :screen_url =>get_photo_url(p, :screen),
          :add_url => facebook_photo_action_path(params.merge(:photo_id => p[:id], :action => 'import', :format => 'json')),
          :source_guid => make_source_guid(p)

        }
      end
    else
      @photos = []
    end
    JSON.fast_generate(@photos)
  end

  def self.import_photo(api_client, params)
    identity = params[:identity]
    info = call_with_error_adapter do
      api_client.get(params[:photo_id])
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :user_id=>identity.user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :work_priority => ZZ::Async::Priorities.import_single_photo,
            :caption => info[:name] || '',
            :capture_date => info[:created_time],
            :source_guid => make_source_guid(info),
            :source_thumb_url => get_photo_url(info, :thumb),
            :source_screen_url => get_photo_url(info, :screen),
            :source => 'facebook'
    )

    queue_single_photo( photo, get_photo_url(info, :full) )
    Photo.to_json_lite(photo)
  end

  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end

end
