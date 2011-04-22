class Connector::PhotobucketFoldersController < Connector::PhotobucketController
  
  def self.list_dir(api, params)

    album_contents = api.open_album(params[:album_path])

Rails.logger.info "--response from photobucket--"
Rails.logger.info album_contents.inspect


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

    JSON.fast_generate(folders)
  end

  def self.import_dir_photos(api, params)
    identity = params[:identity]
    album_contents = api.open_album(params[:album_path])

Rails.logger.info "--response from photobucket--"
Rails.logger.info album_contents.inspect


    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    (album_contents[:media] || []).each do |photo_data|
      photo_url = photo_data[:url]
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => photo_data[:title] || photo_data[:name],
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
              :source_guid => make_source_guid(photo_data[:url]),
              :source_thumb_url => photo_data[:thumb],
              :source_screen_url => photo_data[:thumb],
              :source => 'photobucket'
      })

      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end

  def self.import_certain_photo(api, params)
    identity = params[:identity]
    photo_data = api.call_method("/media/#{params[:photo_path]}")

Rails.logger.info "--response from photobucket--"
Rails.logger.info photo_data.inspect



    
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
            :id => Photo.get_next_id,
            :caption => photo_data[:title] || photo_data[:name],
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (Time.at(photo_data[:uploaddate].to_i) rescue nil),
            :source_guid => make_source_guid(photo_data[:url]),
            :source_thumb_url => photo_data[:thumb],
            :source_screen_url => photo_data[:thumb],
            :source => 'photobucket'

    )
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data[:url] )
    
    Photo.to_json_lite(photo)
  end
  
  
  def index
    fire_async_response('list_dir')
  end

  def import
    fire_async_response('import_dir_photos')
  end

  def import_photo
    fire_async_response('import_certain_photo')
  end

end
