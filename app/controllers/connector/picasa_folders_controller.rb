class Connector::PicasaFoldersController < Connector::PicasaController
  
  def self.list_albums(api, params)
    begin
      feed = api.get("https://picasaweb.google.com/data/feed/api/user/default").body
    rescue GData::Client::UnknownError => e
      if e.message.include?('Unknown user')
        feed = <<-XML
          <?xml version='1.0' encoding='UTF-8'?>
          <feed xmlns='http://www.w3.org/2005/Atom' xmlns:gphoto='http://schemas.google.com/photos/2007' xmlns:media='http://search.yahoo.com/mrss/' xmlns:openSearch='http://a9.com/-/spec/opensearchrss/1.0/'>
          </feed>
        XML
      else
        raise e
      end
    end
    doc = Nokogiri::XML(feed)

    folders = []
    doc.xpath('//a:entry', NS).each do |entry|
      albumid = /albumid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      folders << {
        :name => entry.at_xpath('a:title', NS).text,
        :type => 'folder',
        :id  => albumid,
        :open_url => picasa_photos_path(:picasa_album_id => albumid, :format => 'json'),
        :add_url  => picasa_folder_action_path(:picasa_album_id => albumid, :action => :import, :format => 'json')
      }
    end
    
    JSON.fast_generate(folders)
  end

  def self.import_album(api, params)
    identity = params[:identity]
    doc = Nokogiri::XML(api.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").body)

    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    doc.xpath('//a:entry', NS).each do |entry|
      #photoid = /photoid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      photo_url = get_photo_url(entry.at_xpath('m:group', NS), :full)
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => entry.at_xpath('a:title', NS).text,
              :album_id => params[:album_id],
              :user_id => identity.user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.at(entry.at_xpath('gp:timestamp', NS).text.to_i/1000) rescue nil),
              :source_guid => make_source_guid(entry.at_xpath('m:group', NS)),
              :source_thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
              :source_screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen),
              :source => 'picasaweb'

      })
      
      photo.temp_url = photo_url
      photos << photo
    end

    bulk_insert(photos)
  end

  def index
    fire_async_response('list_albums')
  end

  def import
    fire_async_response('import_album')
  end

end
