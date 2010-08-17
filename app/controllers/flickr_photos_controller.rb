class FlickrPhotosController < FlickrController

  

  def index
    photos_response = flickr_api.photosets.getPhotos :photoset_id => params[:set_id]
#    @photos = photos_response.photo.map { |p| {:name => p.title, :id => p.id} }

    @photos = photos_response.photo.map { |p|
      {
        :name => p.title,
        :id   => p.id,
#        :thumb_url =>  flickr_photo_url({:photo_id =>p.id, :size => 'thumb'}),
#        :screen_url => flickr_photo_url({:photo_id =>p.id, :size => 'screen'}),
        :thumb_url =>  get_photo_url(p, (params[:size] || 'thumb').downcase.to_sym),
        :screen_url =>  get_photo_url(p, (params[:size] || 'screen').downcase.to_sym),
        :add_url => flickr_photo_action_url({:photo_id =>p.id, :action => 'import'})
      }
    }


    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    photo_info = flickr_api.photos.getInfo :photo_id => params[:photo_id]
    @photo_url = get_photo_url(photo_info, (params[:size] || 'screen').downcase.to_sym)
    bin_io = RemoteFile.new(@photo_url)
    send_data bin_io.read, :type => bin_io.content_type, :disposition => 'inline'
  end

  def import
    info = flickr_api.photos.getInfo :photo_id => params[:photo_id]
    photo_url = get_photo_url(info, :full)
    photo = Photo.create(:caption => info.title, :album_id => params[:album_id], :user_id=>current_user.id)
    Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, photo_url))
    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end


end
