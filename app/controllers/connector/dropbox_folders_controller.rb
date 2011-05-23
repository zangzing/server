class Connector::DropboxFoldersController < Connector::DropboxController

  LISTABLE_TYPES = %w(image/jpeg image/gif image/bmp)

  def self.make_thumb_url(entry_path, options = {})
      path = entry_path.sub(/^\//, '')
      rest = Dropbox.check_path(path).split('/')
      rest << { :ssl => @ssl }
      rest.last.merge! options
      url = Dropbox.api_url('thumbnails', 'dropbox', *rest)
  end


  def self.list_dir(api, params)
    api.mode = :metadata_only
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
        #binary_thumb = api.thumbnail(entry.path, :size => 'large')
        thumb = make_thumb_url(entry.path, :size => 'large') #Not working since isn't oauth-signed
        {
          :name => entry_name,
          :id   => entry_id,
          :type => 'photo',
          :thumb_url => thumb,
          :screen_url => thumb,
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
