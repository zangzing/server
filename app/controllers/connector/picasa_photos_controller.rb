class Connector::PicasaPhotosController < Connector::PicasaController

  def index
    doc = Nokogiri::XML(client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").body)
    photos = []
    doc.xpath('//a:entry', NS).each do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      photos << {
        :name => entry.at_xpath('a:title', NS).text,
        :id => photoid,
        :type => 'photo',
        :thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
        :screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen),
        :add_url => picasa_photo_action_path({:picasa_album_id =>params[:picasa_album_id], :photo_id => photoid, :action => 'import'}),
        :source_guid => make_source_guid(entry.at_xpath('m:group', NS))
     }
    end
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(photos)
  end

  def import
    doc = Nokogiri::XML(client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").body)
    photo = nil
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    doc.xpath('//a:entry', NS).each do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      photo_url = get_photo_url(entry.at_xpath('m:group', NS), :full)
      if(photoid==params[:photo_id])
        photo = Photo.create(
                :caption => entry.at_xpath('a:title', NS).text,
                :album_id => params[:album_id],
                :user_id=>current_user.id,
                :upload_batch_id => current_batch.id,
                :capture_date => (Time.at(entry.at_xpath('gp:timestamp', NS).text.to_i/1000) rescue nil),
                :source_guid => make_source_guid(entry.at_xpath('m:group', NS)),
                :source_thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
                :source_screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen)
        )

        ZZ::Async::GeneralImport.enqueue(photo.id,  photo_url)
        break
      end
    end
    render :json => Photo.to_json_lite(photo)
  end

end
