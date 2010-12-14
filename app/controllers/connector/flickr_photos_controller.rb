class Connector::FlickrPhotosController < Connector::FlickrController

  

  def index
    photos_response = flickr_api.photosets.getPhotos :photoset_id => params[:set_id]
#    @photos = photos_response.photo.map { |p| {:name => p.title, :id => p.id} }

    @photos = photos_response.photo.map { |p|
      {
        :name => p.title,
        :id   => p.id,
        :type => 'photo',
        :thumb_url =>  get_photo_url(p, :thumb),
        :screen_url =>  get_photo_url(p, :screen),
        :add_url => flickr_photo_action_url({:photo_id =>p.id, :action => 'import'}),
        :source_guid => Photo.generate_source_guid(get_photo_url(p, :full))
      }
    }

    render :json => @photos.to_json
  end

#  def show
#    photo_info = flickr_api.photos.getInfo :photo_id => params[:photo_id]
#    @photo_url = get_photo_url(photo_info, (params[:size] || 'screen').downcase.to_sym)
#    bin_io = RemoteFile.new(@photo_url)
#    send_data bin_io.read, :type => bin_io.content_type, :disposition => 'inline'
#  end

  def import
    info = flickr_api.photos.getInfo :photo_id => params[:photo_id], :extras => 'original_format'
    photo_url = get_photo_url(info, :full)
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
              :user_id=>current_user.id,
              :album_id => params[:album_id],
              :upload_batch_id => current_batch.id,
              :caption => info.title,
              :source_guid => "flickr:"+Photo.generate_source_guid(photo_url),
              :source_thumb_url => get_photo_url(info, :thumb),
              :source_screen_url => get_photo_url(info, :screen)
    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_url )
    render :json => photo.to_json
  end
end
