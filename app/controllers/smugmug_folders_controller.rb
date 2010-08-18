class SmugmugFoldersController < SmugmugController

  def index
    album_list = smugmug_api.call_method('smugmug.albums.get')
    @folders = album_list.map { |f|
      {
        :name => f[:title],
        :type => 'folder',
        :id  =>  "#{f[:id]}_#{f[:key]}",
        :open_url => smugmug_photos_path("#{f[:id]}_#{f[:key]}"),
        :add_url =>  smugmug_folder_action_path({:sm_album_id =>"#{f[:id]}_#{f[:key]}", :action => 'import'})
      }
    }

    render :json => @folders.to_json
  end

  def import
    album_id, album_key = params[:sm_album_id].split('_')
    photos_list = smugmug_api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    photos = []
    photos_list[:images].each do |p|
      photo = Photo.create(:caption => (p[:caption].blank? ? p[:filename] : p[:caption]), :album_id => params[:album_id], :user_id=>current_user.id)
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, p[:originalurl]))
      photos << photo
    end

    render :json => photos.to_json

  end

end
