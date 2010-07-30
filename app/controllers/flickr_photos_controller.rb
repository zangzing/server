class FlickrPhotosController < FlickrController

  require 'import_requests/flickr_import_request'
  

  def index
    photos_response = flickr_api.photosets.getPhotos :photoset_id => params[:set_id]
    @photos = photos_response.photo.map { |p| {:name => p.title, :id => p.id} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    @photo_url = get_photo_url(params[:photo_id], (params[:size] || 'screen').downcase.to_sym)
    bin_io = RemoteFile.new(@photo_url)
    send_data bin_io.read, :type => bin_io.content_type, :disposition => 'inline'
  end

  def import
    info = flickr_api.photos.getInfo :photo_id => params[:photo_id]
    photo_url = get_photo_url(params[:photo_id], :full)
    photo = Photo.create(:state => 'new', :image_file_name => info.title, :album_id => params[:album_id])
    Delayed::Job.enqueue(FlickrImportRequest.new(photo.id, photo_url, flickr_auth_token))
    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end


end
