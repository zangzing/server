class Connector::PhotobucketFoldersController < Connector::PhotobucketController

  def index
    album_contents = nil
    SystemTimer.timeout_after(http_timeout) do
      album_contents = photobucket_api.open_album(params[:album_path])
    end
    folders = []
    (album_contents[:album] || []).each do |album|
      album_path = params[:album_path].nil? ? CGI::escape(album[:name]) : "#{params[:album_path]}#{CGI::escape('/'+album[:name])}"
      folders << {
        :name => album[:name],
        :type => 'folder',
        :id  => album_path,
        :open_url => photobucket_path(:album_path => album_path),
        :add_url  => photobucket_path(:album_path => album_path, :action => :import)
      }
    end
    (album_contents[:media] || []).each do |media|
      photo_path = params[:album_path].nil? ? CGI::escape(media[:name]) : "#{params[:album_path]}#{CGI::escape('/'+media[:name])}"
      folders <<       {
        :name => media[:title] || media[:name],
        :id   => photo_path,
        :type => 'photo',
        :thumb_url => media[:thumb],
        :screen_url => media[:thumb],
        :add_url => photobucket_path({:photo_path => CGI::escape(media[:url]), :action => 'import_photo'}),
        :source_guid => make_source_guid(media[:url])
      }
    end
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(folders)
  end

  def import
    album_contents = nil
    SystemTimer.timeout_after(http_timeout) do
      album_contents = photobucket_api.open_album(params[:album_path])
    end
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    (album_contents[:media] || []).each do |photo_data|
      photo = Photo.create(
              :caption => photo_data[:title] || photo_data[:name],
              :album_id => params[:album_id],
              :user_id => current_user.id,
              :upload_batch_id => current_batch.id,              
              :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
              :source_guid => make_source_guid(photo_data[:url]),
              :source_thumb_url => photo_data[:thumb],
              :source_screen_url => photo_data[:thumb]
      )
      
      ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url] )
      photos << photo
    end
    render :json => Photo.to_json_lite(photos)
  end

  def import_photo
    photo_data = nil
    SystemTimer.timeout_after(http_timeout) do
      photo_data = photobucket_api.call_method("/media/#{params[:photo_path]}")
    end
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :caption => photo_data[:title] || photo_data[:name],
            :album_id => params[:album_id],
            :user_id => current_user.id,
            :upload_batch_id => current_batch.id,            
            :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
            :source_guid => make_source_guid(photo_data[:url]),
            :source_thumb_url => photo_data[:thumb],
            :source_screen_url => photo_data[:thumb]
    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url] )
    render :json => Photo.to_json_lite(photo)
  end

end
