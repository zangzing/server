class Connector::PicasaPhotosController < Connector::PicasaController

  def index
    doc = client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").to_xml
    photos = []
    doc.elements.each('entry') do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      photos << {
        :name => entry.elements['title'].text,
        :id => photoid,
        :type => 'photo',
        :thumb_url => get_photo_url(entry.elements['media:group'], :thumb),
        :screen_url => get_photo_url(entry.elements['media:group'], :screen),
        :add_url => picasa_photo_action_path({:picasa_album_id =>params[:picasa_album_id], :photo_id => photoid, :action => 'import'}),
        :source_guid => make_source_guid(entry.elements['media:group'])
     }
    end

    render :json => photos.to_json
  end

  def import
    doc = client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").to_xml
    photo = nil
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    doc.elements.each('entry') do |entry|
      photoid = /photoid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      photo_url = get_photo_url(entry.elements['media:group'], :full)
      if(photoid==params[:photo_id])
        photo = Photo.create(
                :caption => entry.elements['title'].text,
                :album_id => params[:album_id],
                :user_id=>current_user.id,
                :upload_batch_id => current_batch.id,
                :source_guid => make_source_guid(entry.elements['media:group']),
                :source_thumb_url => get_photo_url(entry.elements['media:group'], :thumb),
                :source_screen_url => get_photo_url(entry.elements['media:group'], :screen)
        )

        ZZ::Async::GeneralImport.enqueue(photo.id,  photo_url)
        break
      end
    end
    render :json => Photo.to_json_lite(photo)
  end

end
