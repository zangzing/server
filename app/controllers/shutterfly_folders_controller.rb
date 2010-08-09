class ShutterflyFoldersController < ShutterflyController

  def index
    album_list = sf_api.get_albums
    folders = album_list.map { |f| {:name => f[:title], :id => /albumid\/([0-9a-z]+)/.match(f[:id])[1] } }
    respond_to do |wants|
      wants.html { @folders = folders }
      wants.json { render :json => folders.to_json }
    end
  end

  def import
    photos_list = sf_api.get_images(params[:sf_album_id])
    photos = []
    photos_list.each do |p|
      photo = Photo.create(:caption => p[:title], :album_id => params[:album_id], :user_id=>current_user.id)
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, get_photo_url(p[:id], :full)))
      photos << photo
    end
    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

end
