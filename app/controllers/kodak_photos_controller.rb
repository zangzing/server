class KodakPhotosController < KodakController


  def index
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['Album']['pictures']
    @photos = photos_data.map { |p| {:name => p['caption'], :id => p['id']} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['Album']['pictures']
    @photo = photos_data.select { |p| p['id']==params[:photo_id] }.first
    size_wanted = (params[:size] || 'screen').downcase.to_sym
    @photo_url = @photo[PHOTO_SIZES[size_wanted]]
    send_data connector.proxy_response(@photo_url), :type => 'image/jpeg', :filename => "#{@photo['caption'].first.gsub('.', '_')}_#{size_wanted}.jpg", :disposition => 'inline'
  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['Album']['pictures']
    p = photos_data.select { |p| p['id']==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]].first
    photo = Photo.create(:state => 'new', :image_file_name => p['caption'], :album_id => params[:album_id])
    Delayed::Job.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))

    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end


end
