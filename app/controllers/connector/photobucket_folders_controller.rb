class Connector::PhotobucketFoldersController < Connector::PhotobucketController

  def index
    album_contents = photobucket_api.open_album(params[:album_path]).first
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
        :name => media[:title].first.is_a?(Hash) ? media[:name] : media[:title].first,
        :id   => photo_path,
        :type => 'photo',
        :thumb_url => media[:thumb].first,
        :screen_url => media[:thumb].first,
        :add_url => photobucket_path({:photo_path => CGI::escape(media[:url].first), :action => 'import_photo'}),
        :source_guid => make_source_guid(media[:url].first)
      }
    end

    render :json => folders
  end

  def import
    album_contents = photobucket_api.open_album(params[:album_path]).first
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    (album_contents[:media] || []).each do |photo_data|
      photo = Photo.create(
              :caption => photo_data[:title].first.is_a?(Hash) ? photo_data[:name] : photo_data[:title].first,
              :album_id => params[:album_id],
              :user_id => current_user.id,
              :upload_batch_id => current_batch.id,              
              :source_guid => make_source_guid(photo_data[:url].first),
              :source_thumb_url => photo_data[:thumb].first,
              :source_screen_url => photo_data[:thumb].first
      )
      
      ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url].first )
      photos << photo
    end
    render :json => photos.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url])
  end

  def import_photo
    photo_data = photobucket_api.call_method("/media/#{params[:photo_path]}").first
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :caption => photo_data[:title].first.is_a?(Hash) ? photo_data[:name] : photo_data[:title].first,
            :album_id => params[:album_id],
            :user_id => current_user.id,
            :upload_batch_id => current_batch.id,            
            :source_guid => make_source_guid(photo_data[:url].first),
            :source_thumb_url => photo_data[:thumb].first,
            :source_screen_url => photo_data[:thumb].first
    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url].first )
    render :json => photo.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url])
  end

end
