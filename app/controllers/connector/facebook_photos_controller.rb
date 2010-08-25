class Connector::FacebookPhotosController < Connector::FacebookController

  def index
    photos_response = facebook_graph.get("#{params[:fb_album_id]}/photos")
    @photos = photos_response.map { |p|
      {
        :name => p[:name],
        :id   => p[:id],
        :type => 'photo',
        :thumb_url =>get_photo_url(p[:id], PHOTO_SIZES[:thumb]),
        :screen_url =>get_photo_url(p[:id], PHOTO_SIZES[:screen]),
        :add_url => facebook_photo_action_path({:photo_id =>p[:id], :action => 'import'}),
        :source_guid => Photo.generate_source_guid(p[:source])

      }
    }

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
    photo = Photo.create(
            :caption => info[:name],
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :source_guid => Photo.generate_source_guid(info[:source]),
            :source_thumb_url => get_photo_url(info[:id], PHOTO_SIZES[:thumb]),
            :source_screen_url => get_photo_url(info[:id], PHOTO_SIZES[:screen])
    )





    Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, info[:source]))
    render :json => photo.to_json
  end

end
