class Connector::FacebookPhotosController < Connector::FacebookController

  def index
    photos_response = facebook_graph.get("#{params[:fb_album_id]}/photos")
    unless photos_response.empty?
      if photos_response.first[:updated_time]
        photos_response.sort!{|a, b| b[:updated_time] <=> a[:updated_time] }
      end
      @photos = photos_response.map { |p|
        {
          :name => p[:name] || '',
          :id   => p[:id],
          :type => 'photo',
          :thumb_url =>get_photo_url(p, :thumb),
          :screen_url =>get_photo_url(p, :screen),
          :add_url => facebook_photo_action_path({:photo_id =>p[:id], :action => 'import'}),
          :source_guid => make_source_guid(p)

        }
      }
    else
      @photos = []
    end

    render :json => @photos.to_json
  end

#  def show
#    size_wanted = (params[:size] || 'screen').downcase.to_sym
#    photo_url = get_photo_url(params[:photo_id], PHOTO_SIZES[size_wanted])
#    bin_io = OpenURI.send(:open, photo_url)
#    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
#  end

  def import
    info = facebook_graph.get(params[:photo_id])
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :user_id=>current_user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :caption => info[:name] || '',
            :source_guid => make_source_guid(info),
            :source_thumb_url => get_photo_url(info, :thumb),
            :source_screen_url => get_photo_url(info, :screen)
    )
  
    ZZ::Async::GeneralImport.enqueue( photo.id, get_photo_url(info, :full) )
    render :json => photo.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url])
  end

end
