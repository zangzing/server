class Connector::SmugmugPhotosController < Connector::SmugmugController

  def index
    album_id, album_key = params[:sm_album_id].split('_')
    photos_response = smugmug_api.call_method('smugmug.images.get', {:AlbumID => album_id, :AlbumKey => album_key, :Heavy => 1})
    @photos = photos_response[:images].map { |p|
      {
        :name => (p[:caption].blank? ? p[:filename] : p[:caption]),
        :id   => "#{p[:id]}_#{p[:key]}",
        :type => 'photo',
        :thumb_url => '/proxy?url=' + p[:smallurl],
        :screen_url => '/proxy?url=' + p[:x3largeurl],
        :add_url => smugmug_photo_action_url({:sm_album_id =>album_id, :photo_id => "#{p[:id]}_#{p[:key]}", :action => 'import'}),
        :source_guid => Photo.generate_source_guid(p[:originalurl])
        
      }
    }


    render :json => @photos.to_json
  end

#  def show
#    photo_id, photo_key = params[:photo_id].split('_')
#    photo_info = smugmug_api.call_method('smugmug.images.getURLs', {:ImageID => photo_id, :ImageKey => photo_key})
#    size_wanted = (params[:size] || :screen).to_sym
#    photo_url = photo_info[PHOTO_SIZES[size_wanted]]
#    bin_io = OpenURI.send(:open, photo_url)
#    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
#  end

  def import
    photo_id, photo_key = params[:photo_id].split('_')
    photo_info = smugmug_api.call_method('smugmug.images.getInfo', {:ImageID => photo_id, :ImageKey => photo_key})
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :caption => (photo_info[:caption].blank? ? photo_info[:filename] : photo_info[:caption]),
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :upload_batch_id => current_batch.id,
            :source_guid => "smugmug:"+Photo.generate_source_guid(photo_info[:originalurl]),
            :source_thumb_url => '/proxy?url=' + photo_info[:smallurl],
            :source_screen_url => '/proxy?url=' + photo_info[:x3largeurl]

    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id,  photo_info[:originalurl] )
    render :json => photo.to_json

  end

end
