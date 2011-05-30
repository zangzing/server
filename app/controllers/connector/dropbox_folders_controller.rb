class Connector::DropboxFoldersController < Connector::DropboxController

  LISTABLE_TYPES = %w(image/jpeg image/gif image/bmp)

  def self.make_signed_url(access_token, entry_path, options = {})
      path = entry_path.sub(/^\//, '')
      rest = Dropbox.check_path(path).split('/')
      rest << { :ssl => false }
      rest.last.merge! options
      url = Dropbox.api_url('thumbnails', 'dropbox', *rest)
      request_uri = URI.parse(url)

      http = Net::HTTP.new(request_uri.host, request_uri.port)
      req = Net::HTTP::Get.new(request_uri.request_uri)   
      req.oauth!(http, access_token.consumer, access_token, {:scheme => :query_string})
      "#{request_uri.scheme}://#{request_uri.host}#{req.path}"
  end


  def self.list_dir(api, params)
    api.mode = :metadata_only
    #api.access_token.consumer.options[:scheme] = :query_string
    path = params[:path] || '/'
    list = api.list(path)
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



  def index
    render :json => self.class.list_dir(dropbox_api, params)
  end

  def import_folder

  end

  def import_photo

  end

end
