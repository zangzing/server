class SmugmugFoldersController < SmugmugController

  def index
    album_list = smugmug_api.call_method('smugmug.albums.get')
    @folders = album_list.map { |f| {:name => f[:title], :id => "#{f[:id]}_#{f[:key]}"} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
  end

  def import
    album_id, album_key = params[:sm_album_id].split('_')
    photos_list = smugmug_api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    photos = []
    photos_list[:images].each do |p|
      photo = Photo.create(:caption => (p[:caption].blank? ? p[:filename] : p[:caption]), :album_id => params[:album_id], :user_id=>current_user.id)
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, p[:originalurl]))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

end
