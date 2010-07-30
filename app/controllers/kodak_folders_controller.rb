class KodakFoldersController < KodakController

  require 'import_requests/kodak_import_request'


  def index
    album_list = connector.send_request('/albumList')
    albums = album_list['Album'].select { |a| a['type'].first=='0' } #Real albums have type attribute = 0
    @folders = albums.map { |f| {:name => f['name'].first, :id => f['id'].first} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    photos = []
    photos_data.each do |p|
      photo_url = p[PHOTO_SIZES[:full]].first
      photo = Photo.create(:state => 'new', :image_file_name => p['caption'].first, :album_id => params[:album_id])
      Delayed::Job.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

end
