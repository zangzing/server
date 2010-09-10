class Connector::ZangzingPhotosController < Connector::ConnectorController

  def index
    @photos = current_user.albums.find(params[:zz_album_id]).photos.all(:conditions=>{ :state=>'ready'}).map do |p|
      {
        :name => p.caption,
        :id   => p.id,
        :type => 'photo',
        :thumb_url => p.thumb_url,
        :screen_url => p.medium_url,
        :add_url => zangzing_photo_action_path({:photo_id => p.id, :action => 'import'}),
        :source_guid => p.source_guid
      }
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
    source_photo = current_user.albums.find(params[:zz_album_id]).photos.find(params[:photo_id])
    photo = Photo.create(
              :caption => source_photo.caption,
              :album_id => params[:album_id],
              :user_id => source_photo.user_id,
              :source_guid => source_photo.source_guid,
              :source_thumb_url => source_photo.source_thumb_url,
              :source_screen_url => source_photo.source_screen_url
    )

    Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, source_photo.image.url))
    render :json => photo.to_json
  end

end
