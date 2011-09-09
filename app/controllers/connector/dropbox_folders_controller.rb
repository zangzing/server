class Connector::DropboxFoldersController < Connector::DropboxController

  LISTABLE_TYPES = Photo.supported_image_types.to_a

  def self.list_dir(api, params)
    path = params[:path] || '/'
    list = call_with_error_adapter do
      api.list(path)
    end
    contents = list.map do |entry|
      entry_id = Base64::encode64(entry.path)
      entry_name = File.split(entry.path).last
      if entry.is_dir
        {
          :name => entry_name,
          :type => 'folder',
          :id  => entry_id,
          :open_url => dropbox_path(:path => entry.path),
          :add_url  => dropbox_path(:path => entry.path, :action => :import_folder)
        }
      elsif LISTABLE_TYPES.include?(entry.mime_type)
        {
          :name => entry_name,
          :id   => entry_id,
          :type => 'photo',
          :thumb_url => dropbox_image_path(:root => 'thumbnails', :path => entry.path, :size => 'm'),
          :screen_url => dropbox_image_path(:root => 'thumbnails', :path => entry.path, :size => 'l'),
          :add_url => dropbox_path(:photo_path => entry.path, :action => :import_photo),
          :source_guid => make_source_guid(entry.path)
        }
      end
    end
    contents.compact
  end
  
  def self.import_whole_folder(api, params)
    identity = params[:identity]
    list = call_with_error_adapter do
      api.list(params[:path])
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photos = list.select{|entry| !entry.is_dir && LISTABLE_TYPES.include?(entry.mime_type) }.map do |entry|
      Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => File.split(entry.path).last,
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.parse(entry.modified) rescue nil),
              :source_guid => make_source_guid(entry.path),
              :source_thumb_url => dropbox_image_path(:root => 'thumbnails', :path => entry.path, :size => 'm'),
              :source_screen_url => dropbox_image_path(:root => 'thumbnails', :path => entry.path, :size => 'l'),
              :source => 'dropbox'
            }).tap do |p|
              p.temp_url = entry.path
            end
    end

    # bulk insert
    Photo.batch_insert(photos)
    # must send after all saved
    photos.each do |photo|
      ZZ::Async::GeneralImport.enqueue( photo.id, photo.temp_url, :url_making_method => 'Connector::DropboxUrlsController.get_file_signed_url', :inplace_retries => 2 )
    end
    Photo.to_json_lite(photos)
  end
  
  def self.import_certain_photo(api, params)
    identity = params[:identity]
    photo_data = call_with_error_adapter do
      api.metadata(params[:photo_path])
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo_url = dropbox_image_url(:root => 'files', :path => photo_data.path, :host => Server::Application.config.application_host)
    photo = Photo.create(
              :id => Photo.get_next_id,
              :caption => File.split(photo_data.path).last,
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.parse(photo_data.modified) rescue nil),
              :source_guid => make_source_guid(photo_data.path),
              :source_thumb_url => dropbox_image_path(:root => 'thumbnails', :path => photo_data.path, :size => 'm'),
              :source_screen_url => dropbox_image_path(:root => 'thumbnails', :path => photo_data.path, :size => 'l'),
              :source => 'dropbox'
    ).tap do |p|
      p.temp_url = photo_url
    end
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_data.path, :url_making_method => 'Connector::DropboxUrlsController.get_file_signed_url', :inplace_retries => 2 )

    Photo.to_json_lite(photo)
  end


  def index
    fire_async_response('list_dir')
  end

  def import_folder
    fire_async_response('import_whole_folder')
  end

  def import_photo
    fire_async_response('import_certain_photo')
  end
  
end
