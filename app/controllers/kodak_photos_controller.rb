class KodakPhotosController < KodakController


  def index
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    @photos = photos_data.map { |p| {:name => p['caption'].first, :id => p['id'].first} }
    respond_to do |wants|
      wants.html
      wants.json { render :json => @photos.to_json }
    end
  end

  def show
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    @photo = photos_data.select { |p| p['id'].first==params[:photo_id] }.first
    size_wanted = (params[:size] || 'screen').downcase.to_sym
    @photo_url = @photo[PHOTO_SIZES[size_wanted]].first
    send_data connector.proxy_response(@photo_url), :type => 'image/jpeg', :filename => "#{@photo['caption'].first.gsub('.', '_')}_#{size_wanted}.jpg", :disposition => 'inline'
  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    p = photos_data.select { |p| p['id'].first==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]].first
    photo = Photo.create(:caption => p['caption'].first, :album_id => params[:album_id], :user_id=>current_user.id)
    Delayed::Job.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))

    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end


end
