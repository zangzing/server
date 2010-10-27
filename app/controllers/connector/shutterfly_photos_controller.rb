class Connector::ShutterflyPhotosController < Connector::ShutterflyController

  def index
    photos_list = sf_api.get_images(params[:sf_album_id])
    photos = photos_list.map { |p|
     {
        :name => p[:title].first,
        :id => p[:id].first,
        :type => 'photo',
        :thumb_url => get_photo_url(p[:id].first, :thumb),
        :screen_url => get_photo_url(p[:id].first, :screen),
        :add_url => shutterfly_photo_action_path({:sf_album_id =>params[:sf_album_id], :photo_id => p[:id].first, :action => 'import'}),
        :source_guid => Photo.generate_source_guid(get_photo_url(p[:id],  :full))

     }
    }

    render :json => photos.to_json

  end

#  def show
#    photo_url = get_photo_url(params[:photo_id], (params[:size] || :screen).to_sym)
#    bin_io = OpenURI.send(:open, photo_url)
#    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
#  end

  def import
    photos_list = sf_api.get_images(params[:sf_album_id])
    photo_title = photos_list.select { |p| p[:id].first==params[:photo_id] }.first[:title].first
    photo_url = get_photo_url(params[:photo_id],  :full)
    photo = Photo.create(
            :caption => photo_title,
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :source_guid => Photo.generate_source_guid(photo_url),
            :source_thumb_url => get_photo_url(params[:photo_id],  :thumb),
            :source_screen_url => get_photo_url(params[:photo_id],  :screen)
    )
    Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, photo_url))

    render :json => photo.to_json

  end

end
