class Connector::PicasaFoldersController < Connector::PicasaController

  def index
    doc = nil
    SystemTimer.timeout_after(http_timeout) do
      doc = Nokogiri::XML(client.get("https://picasaweb.google.com/data/feed/api/user/default").body)
    end
    folders = []
    doc.xpath('//a:entry', NS).each do |entry|
      albumid = /albumid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      folders << {
        :name => entry.at_xpath('a:title', NS).text,
        :type => 'folder',
        :id  => albumid,
        :open_url => picasa_photos_path(:picasa_album_id => albumid),
        :add_url  => picasa_folder_action_path(:picasa_album_id => albumid, :action => :import)
      }
    end
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(folders)
  end

  def import
    doc = nil
    SystemTimer.timeout_after(http_timeout) do
      doc = Nokogiri::XML(client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").body)
    end
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    doc.xpath('//a:entry', NS).each do |entry|
      #photoid = /photoid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      photo_url = get_photo_url(entry.at_xpath('m:group', NS), :full)
      photo = Photo.new_for_batch(current_batch, {
              :id => Photo.get_next_id,
              :caption => entry.at_xpath('a:title', NS).text,
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :upload_batch_id => current_batch.id,
              :capture_date => (Time.at(entry.at_xpath('gp:timestamp', NS).text.to_i/1000) rescue nil),
              :source_guid => make_source_guid(entry.at_xpath('m:group', NS)),
              :source_thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
              :source_screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen)
      })
      
      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end

end
