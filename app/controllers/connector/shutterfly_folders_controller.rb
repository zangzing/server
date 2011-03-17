class Connector::ShutterflyFoldersController < Connector::ShutterflyController

  def index
    album_list = nil
    SystemTimer.timeout_after(http_timeout) do
      album_list = sf_api.get_albums
    end
    folders = album_list.map { |f|
      {
        :name => f[:title],
        :type => 'folder',
        :id  =>  /albumid\/([0-9a-z]+)/.match(f[:id])[1],
        :open_url => shutterfly_photos_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id])[1]),
        :add_url  => shutterfly_folder_action_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id])[1], :action => :import)
      }
    }
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(folders)
  end

  def import
    photos_list = nil
    SystemTimer.timeout_after(http_timeout) do
      photos_list = sf_api.get_images(params[:sf_album_id])
    end
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_list.each do |p|
      photo_url = get_photo_url(p[:id], :full)
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => p[:title],
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :upload_batch_id => current_batch.id,              
              :capture_date => (Time.at(p[:capturetime].to_i/1000) rescue nil),
              :source_guid => make_source_guid(p),
              :source_thumb_url => get_photo_url(p[:id],  :thumb),
              :source_screen_url => get_photo_url(p[:id],  :screen)
      })
      
      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end
end
