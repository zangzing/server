class Connector::PicasaFoldersController < Connector::PicasaController

  def index
    doc = client.get("https://picasaweb.google.com/data/feed/api/user/default").to_xml
    folders = []
    doc.elements.each('entry') do |entry|
      albumid = /albumid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      folders << {
        :name => entry.elements['title'].text,
        :type => 'folder',
        :id  => albumid,
        :open_url => picasa_photos_path(:picasa_album_id => albumid),
        :add_url  => picasa_folder_action_path(:picasa_album_id => albumid, :action => :import)
      }
    end
    
    render :json => folders.to_json
  end

  def import
    doc = client.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{params[:picasa_album_id]}").to_xml
    photos = []
    doc.elements.each('entry') do |entry|
      #photoid = /photoid\/([0-9a-z]+)/.match(entry.elements['id'].text)[1]
      photo = Photo.create(
              :caption => entry.elements['title'].text,
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :source_guid => Photo.generate_source_guid(photo_url),
              :source_thumb_url => get_photo_url(entry.elements['media:group'], :thumb),
              :source_screen_url => get_photo_url(entry.elements['media:group'], :screen)
      )
      #Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, get_photo_url(entry.elements['media:group'], :full)))
      ZZ::Async::GeneralImport.enqueue( photo.id,  get_photo_url(entry.elements['media:group'], :full) )
      photos << photo
    end
    render :json => photos.to_json
  end

end
