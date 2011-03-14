class Connector::ShutterflyPhotosController < Connector::ShutterflyController

  def index
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = sf_api.get_images(params[:sf_album_id])
    end
    File.open("#{Rails.root}/#{params[:sf_album_id]}.yml", 'w'){|f| f.write(YAML.dump(photos_list))}
    photos = photos_list.map { |p|
     {
        :name => p[:title],
        :id => p[:id],
        :type => 'photo',
        :thumb_url => get_photo_url(p[:id], :thumb),
        :screen_url => get_photo_url(p[:id], :screen),
        :add_url => shutterfly_photo_action_path({:sf_album_id =>params[:sf_album_id], :photo_id => p[:id], :action => 'import'}),
        :source_guid => make_source_guid(p)

     }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(photos)

  end

#  def show
#    photo_url = get_photo_url(params[:photo_id], (params[:size] || :screen).to_sym)
#    bin_io = OpenURI.send(:open, photo_url)
#    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
#  end

  def import
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = sf_api.get_images(params[:sf_album_id])
    end
    photo_info = photos_list.select { |p| p[:id]==params[:photo_id] }.first
    photo_title = photo_info[:title]
    
    photo_url = get_photo_url(params[:photo_id],  :full)
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :caption => photo_title,
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (Time.at(photo_info[:capturetime].to_i/1000) rescue nil),
            :source_guid => make_source_guid(photo_info),
            :source_thumb_url => get_photo_url(params[:photo_id],  :thumb),
            :source_screen_url => get_photo_url(params[:photo_id],  :screen)
    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id,  photo_url )
    render :json => Photo.to_json_lite(photo)

  end

end
