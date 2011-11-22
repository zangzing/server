class Connector::ShutterflyFoldersController < Connector::ShutterflyController

  def self.folder_list(api_client, params)
    album_list = call_with_error_adapter do
      api_client.get_albums
    end
    folders = album_list.map do |f|
      {
        :name => f[:title],
        :type => 'folder',
        :id  =>  /albumid\/([0-9a-z]+)/.match(f[:id])[1],
        :open_url => shutterfly_photos_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id])[1], :format => 'json'),
        :add_url  => shutterfly_folder_action_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id])[1], :action => :import, :format => 'json')
      }
    end
    JSON.fast_generate(folders)
  end

  def self.import_folder(api_client, params)
    identity = params[:identity]
    photos_list = call_with_error_adapter do
      api_client.get_images(params[:sf_album_id])
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photos_list.each do |p|
      photo_url = get_photo_url(p[:id], :full)
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => p[:title],
              :album_id => params[:album_id],
              :user_id=>identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => p[:capturetime].nil? ? nil : Time.at(p[:capturetime].to_i/1000),
              :source_guid => make_source_guid(p),
              :source_thumb_url => get_photo_url(p[:id],  :thumb),
              :source_screen_url => get_photo_url(p[:id],  :screen),
              :source => 'shutterfly'
      })
      photo.temp_url = photo_url
      photos << photo
    end

    bulk_insert(photos)
  end
  
  def self.import_all_folders(api_client, params)
    identity = params[:identity]
    zz_albums = []
    album_list = call_with_error_adapter do
      api_client.get_albums
    end
    album_list.each do |sf_album|
      zz_album = create_album(identity, sf_album[:title], params[:privacy])
      sf_album_id = /albumid\/([0-9a-z]+)/.match(sf_album[:id])[1]
      zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id}
      fire_async('import_folder', params.merge(:album_id => zz_album.id, :sf_album_id => sf_album_id))
    end

    identity.last_import_all = Time.now
    identity.save


    JSON.fast_generate(zz_albums)
  end  

  def index
    fire_async_response('folder_list')
  end

  def import
    fire_async_response('import_folder')
  end

  def import_all
    fire_async_response('import_all_folders')
  end

end
