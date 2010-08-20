class KodakPhotosController < KodakController


  def index
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
#    @photos = photos_data.map { |p| {:name => p['caption'].first, :id => p['id'].first} }

    @photos = photos_data.map { |p|
      {
        :name => p['caption'].first,
        :id   => p['id'].first,
        :type => 'photo',
        :thumb_url =>p[PHOTO_SIZES[:thumb]].first,
        :screen_url =>p[PHOTO_SIZES[:screen]].first,
        :add_url => kodak_photo_action_path({:kodak_album_id => params[:kodak_album_id], :photo_id => p['id'].first, :action => 'import'}),
        :source_guid => Photo.generate_source_guid(p[PHOTO_SIZES[:full]].first)

      }
    }

    render :json => @photos.to_json
    
  end

#  def show
#    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
#    photos_data = photos_list['pictures']
#    @photo = photos_data.select { |p| p['id'].first==params[:photo_id] }.first
#    size_wanted = (params[:size] || 'screen').downcase.to_sym
#    @photo_url = @photo[PHOTO_SIZES[size_wanted]].first
#    send_data connector.proxy_response(@photo_url), :type => 'image/jpeg', :filename => "#{@photo['caption'].first.gsub('.', '_')}_#{size_wanted}.jpg", :disposition => 'inline'
#  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    p = photos_data.select { |p| p['id'].first==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]].first
    photo = Photo.create(
            :caption => p['caption'].first,
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :source_guid => Photo.generate_source_guid(photo_url),
            :source_thumb_url => p[PHOTO_SIZES[:thumb]].first,
            :source_screen_url => p[PHOTO_SIZES[:screen]].first
    )
    Delayed::Job.enqueue(KodakImportRequest.new(photo.id, photo_url, connector.auth_token))

    render :json => photo.to_json
  end
end
