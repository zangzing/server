class Connector::SmugmugFoldersController < Connector::SmugmugController

  def index
    album_list = smugmug_api.call_method('smugmug.albums.get', :Extras => 'Passworded,PasswordHint,Password')
    @folders = album_list.map { |f|
      {
        :name => f[:title],
        :type => 'folder',
        :id  =>  "#{f[:id]}_#{f[:key]}",
        :open_url => smugmug_photos_path("#{f[:id]}_#{f[:key]}"),
        :add_url =>  smugmug_folder_action_path({:sm_album_id =>"#{f[:id]}_#{f[:key]}", :action => 'import'})
      }
    }

    render :json => JSON.fast_generate(@folders)
  end

  def import
    album_id, album_key = params[:sm_album_id].split('_')
    photos_list = smugmug_api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_list[:images].each do |p|
      photo = Photo.create(
              :caption => (p[:caption].blank? ? p[:filename] : p[:caption]),
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :upload_batch_id => current_batch.id,
              :source_guid => make_source_guid(p),
              :source_thumb_url => '/proxy?url=' + p[:smallurl],
              :source_screen_url => '/proxy?url=' + p[:x3largeurl]
      )
      
      ZZ::Async::GeneralImport.enqueue( photo.id,  p[:originalurl] )
      photos << photo
    end

    render :json => Photo.to_json_lite(photos)

  end

end
