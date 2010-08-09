class FacebookPhotosController < FacebookController

  def index
    photos_response = facebook_graph.get("#{params[:fb_album_id]}/photos")
    @photos = photos_response.map { |p| {:name => p[:name], :id => p[:id]} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    size_wanted = (params[:size] || 'screen').downcase.to_sym
    photo_url = get_photo_url(params[:photo_id], PHOTO_SIZES[size_wanted])
    bin_io = OpenURI.send(:open, photo_url)
    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
  end

  def import
    info = facebook_graph.get(params[:photo_id])
    photo = Photo.create(:caption => info[:name], :album_id => params[:album_id], :user_id=>current_user.id)
    Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, info[:source]))
    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end

end
