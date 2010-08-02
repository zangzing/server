class FlickrFoldersController < FlickrController



  def index
    folders_response = flickr_api.photosets.getList
    @folders = folders_response.map { |f| {:name => f.title, :id => f.id} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
  end

  def import
    photo_set = flickr_api.photosets.getPhotos :photoset_id => params[:set_id]
    photos = []
    photo_set.photo.each do |p|
      photo_url = get_photo_url(p.id, :full)
      photo = Photo.create(:state => 'new', :image_file_name => p.title, :album_id => params[:album_id])
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, photo_url, flickr_auth_token))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

  
end
