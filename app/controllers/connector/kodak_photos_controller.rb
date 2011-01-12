class Connector::KodakPhotosController < Connector::KodakController


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
        :source_guid => make_source_guid(p)

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
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :user_id=>current_user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :caption => p['caption'].first,
            :source_guid => make_source_guid(p),
            :source_thumb_url => p[PHOTO_SIZES[:thumb]].first,
            :source_screen_url => p[PHOTO_SIZES[:screen]].first
    )
    
    ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
    render :json => Photo.to_json_lite(photo)
  end
end
