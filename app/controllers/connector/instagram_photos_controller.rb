class Connector::InstagramPhotosController < Connector::InstagramController

  def index
    photo_list = client.user_media_feed(feed_owner)
    photo_list.reject! { |item| item[:type] != 'image' }
    photos = photo_list.map { |p|
      {
        :name => (p[:caption][:text] rescue ''),
        :id   => p[:id],
        :type => 'photo',
        :thumb_url => p[:images][:thumbnail][:url],
        :screen_url =>p[:images][:low_resolution][:url],
        :add_url => instagram_photo_action_path(:photo_id => p[:id], :action => 'import'),
        :source_guid => make_source_guid(p)
      }
    }

    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(photos)
  end

  def import
    photo_data = client.media_item(params[:photo_id])
    current_batch = UploadBatch.get_current(current_user.id, params[:album_id])
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => (photo_data[:caption][:text] rescue ''),
            :album_id => params[:album_id],
            :user_id => current_user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (Time.at(photo_data[:created_time].to_i) rescue nil),
            :source_guid => make_source_guid(photo_data),
            :source_thumb_url => photo_data[:images][:thumbnail][:url],
            :source_screen_url => photo_data[:images][:low_resolution][:url]
    )

    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:images][:standard_resolution][:url] )
    render :json => Photo.to_json_lite(photo)
  end

end
