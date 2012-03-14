class Connector::PicasaPhotosController < Connector::PicasaController
  
  def self.list_photos(api, params)
    doc = call_with_error_adapter do
      Nokogiri::XML(api.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}?imgmax=d").body)
    end
    photos = []
    doc.xpath('//a:entry', NS).each do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      photos << {
        :name => entry.at_xpath('a:title', NS).text,
        :id => photoid,
        :type => 'photo',
        :thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
        :screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen),
        :add_url => picasa_photo_action_path(params.merge(:picasa_album_id => params[:picasa_album_id], :photo_id => photoid, :action => 'import', :format => 'json')),
        :source_guid => make_source_guid(entry.at_xpath('m:group', NS))
     }
    end
    
    JSON.fast_generate(photos)
  end

  def self.import_photo(api, params)
    identity = params[:identity]
    doc = call_with_error_adapter do
      Nokogiri::XML(api.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}?imgmax=d").body)
    end
    photo = nil
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    doc.xpath('//a:entry', NS).each do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.at_xpath('a:id', NS).text)[1]
      photo_url = get_photo_url(entry.at_xpath('m:group', NS), :full)
      if(photoid==params[:photo_id])
        photo = Photo.create(
                :id => Photo.get_next_id,
                :caption => entry.at_xpath('a:title', NS).text,
                :album_id => params[:album_id],
                :user_id => identity.user.id,
                :upload_batch_id => current_batch.id,
                :work_priority => ZZ::Async::Priorities.import_single_photo,
                :capture_date => (Time.at(entry.at_xpath('gp:timestamp', NS).text.to_i/1000) rescue nil),
                :source_guid => make_source_guid(entry.at_xpath('m:group', NS)),
                :source_thumb_url => get_photo_url(entry.at_xpath('m:group', NS), :thumb),
                :source_screen_url => get_photo_url(entry.at_xpath('m:group', NS), :screen),
                :source => 'picasaweb'
        )

        queue_single_photo(photo,  photo_url)
        break
      end
    end
    Photo.to_json_lite(photo)
  end

  
  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end

end
