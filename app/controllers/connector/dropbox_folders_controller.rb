class Connector::DropboxFoldersController < Connector::DropboxController

  LISTABLE_TYPES = %w(image/jpeg image/gif image/bmp)

  def self.make_signed_url(access_token, entry_path, options = {})
      root = options.delete(:root) || 'thumbnails'
      path = entry_path.sub(/^\//, '')
      rest = Dropbox.check_path(path).split('/')
      rest << { :ssl => false }
      rest.last.merge! options
      url = Dropbox.api_url(root, 'dropbox', *rest)
      request_uri = URI.parse(url)

      http = Net::HTTP.new(request_uri.host, request_uri.port)
      req = Net::HTTP::Get.new(request_uri.request_uri)   
      req.oauth!(http, access_token.consumer, access_token, {:scheme => :query_string})
      "#{request_uri.scheme}://#{request_uri.host}#{req.path}"
  end


  def self.list_dir(api, params)
    api.mode = :metadata_only
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
          :thumb_url => make_signed_url(api.access_token, entry.path, :size => 'm'),
          :screen_url => make_signed_url(api.access_token, entry.path, :size => 'l'),
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
              :source_thumb_url => make_signed_url(api.access_token, entry.path, :size => 'm'),
              :source_screen_url => make_signed_url(api.access_token, entry.path, :size => 'l'),
              :source => 'dropbox',
              :temp_url => make_signed_url(api.access_token, entry.path, :root => 'files')
      })
    end

    bulk_insert(photos)
  end
  
  def self.import_certain_photo(api, params)
    identity = params[:identity]
    photo_data = call_with_error_adapter do
      api.metadata(params[:photo_path])
    end
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
              :id => Photo.get_next_id,
              :caption => File.split(photo_data.path).last,
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.parse(photo_data.modified) rescue nil),
              :source_guid => make_source_guid(photo_data.path),
              :source_thumb_url => make_signed_url(api.access_token, photo_data.path, :size => 'm'),
              :source_screen_url => make_signed_url(api.access_token, photo_data.path, :size => 'l'),
              :source => 'dropbox',
              :temp_url => make_signed_url(api.access_token, photo_data.path, :root => 'files')
    )
    ZZ::Async::GeneralImport.enqueue( photo.id, make_signed_url(api.access_token, photo_data.path, :root => 'files') )

    Photo.to_json_lite(photo)
  end


  def index
    render :json => self.class.list_dir(dropbox_api, params)
  end

  def import_folder
    render :json => self.class.import_certain_photo(dropbox_api, params)
  end

  def import_photo
    render :json => self.class.import_whole_folder(dropbox_api, params)
  end
  
end
