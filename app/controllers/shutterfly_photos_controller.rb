class ShutterflyPhotosController < ShutterflyController

  def index
    album_id, album_key = params[:sm_album_id].split('_')
    photos_response = Shutterfly_api.call_method('Shutterfly.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    @photos = photos_response[:images].map { |p| {:name => (p[:caption].blank? ? p[:filename] : p[:caption]), :id => "#{p[:id]}_#{p[:key]}" } }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    photo_id, photo_key = params[:photo_id].split('_')
    photo_info = Shutterfly_api.call_method('Shutterfly.images.getURLs', {:ImageID => photo_id, :ImageKey => photo_key})
    size_wanted = (params[:size] || :screen).to_sym
    photo_url = photo_info[PHOTO_SIZES[size_wanted]]
    bin_io = OpenURI.send(:open, photo_url)
    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
  end

  def import
    photo_id, photo_key = params[:photo_id].split('_')
    photo_info = Shutterfly_api.call_method('Shutterfly.images.getInfo', {:ImageID => photo_id, :ImageKey => photo_key})
    photo = Photo.create(:state => 'new', :image_file_name => (photo_info[:caption].blank? ? photo_info[:filename] : photo_info[:caption]), :album_id => params[:album_id])
    Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, photo_info[:originalurl]))
    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end

end
