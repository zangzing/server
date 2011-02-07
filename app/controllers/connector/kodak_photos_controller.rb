class Connector::KodakPhotosController < Connector::KodakController


  def index
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
#    @photos = photos_data.map { |p| {:name => p['caption'], :id => p['id']} }

    @photos = photos_data.map { |p|
      {
        :name => p['caption'],
        :id   => p['id'],
        :type => 'photo',
        :thumb_url =>p[PHOTO_SIZES[:thumb]],
        :screen_url =>p[PHOTO_SIZES[:screen]],
        :add_url => kodak_photo_action_path({:kodak_album_id => params[:kodak_album_id], :photo_id => p['id'], :action => 'import'}),
        :source_guid => make_source_guid(p)

      }
    }
    #expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@photos)
    
  end

#  def show
#    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
#    photos_data = photos_list['pictures']
#    @photo = photos_data.select { |p| p['id']==params[:photo_id] }
#    size_wanted = (params[:size] || 'screen').downcase.to_sym
#    @photo_url = @photo[PHOTO_SIZES[size_wanted]]
#    send_data connector.proxy_response(@photo_url), :type => 'image/jpeg', :filename => "#{@photo['caption'].gsub('.', '_')}_#{size_wanted}.jpg", :disposition => 'inline'
#  end

  def import
    photos_list = connector.send_request("/album/#{params[:kodak_album_id]}")
    photos_data = photos_list['pictures']
    p = photos_data.select { |p| p['id']==params[:photo_id] }.first
    photo_url = p[PHOTO_SIZES[:full]]
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :user_id=>current_user.id,
            :album_id => params[:album_id],
            :upload_batch_id => current_batch.id,
            :capture_date => (DateTime.parse(photos_list['userEditedDate']) rescue 1.month.ago),
            :caption => p['caption'],
            :source_guid => make_source_guid(p),
            :source_thumb_url => p[PHOTO_SIZES[:thumb]],
            :source_screen_url => p[PHOTO_SIZES[:screen]]
    )
    
    ZZ::Async::KodakImport.enqueue( photo.id, photo_url, connector.auth_token )
    render :json => Photo.to_json_lite(photo)
  end
end
