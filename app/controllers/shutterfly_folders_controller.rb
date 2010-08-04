class ShutterflyFoldersController < ShutterflyController

  def index
    album_list = sf_api.get_albums
    render :text => album_list
=begin
    @folders = album_list.map { |f| {:name => f[:title], :id => "#{f[:id]}_#{f[:key]}"} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
=end
  end

  def test
    render :text => sf_api.call_api("/userid/#{sf_api.userid_token}/auth")
  end

  def import
    album_id, album_key = params[:sm_album_id].split('_')
    photos_list = Shutterfly_api.call_method('Shutterfly.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    photos = []
    photos_list[:images].each do |p|
      photo = Photo.create(:state => 'new', :image_file_name => (p[:caption].blank? ? p[:filename] : p[:caption]), :album_id => params[:album_id])
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, p[:originalurl]))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

end
