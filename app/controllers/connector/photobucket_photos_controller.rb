class Connector::PhotobucketPhotosController < Connector::PhotobucketController

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
        :source_guid => make_source_guid(p[:originalurl])
        
      }
    }


    render :json => @photos.to_json
  end

  def import
    photo_id, photo_key = params[:photo_id].split('_')
    #What is this smugmug code doing here? Have we tested this?
    photo_info = smugmug_api.call_method('smugmug.images.getInfo', {:ImageID => photo_id, :ImageKey => photo_key})
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photo = Photo.create(
            :caption => (photo_info[:caption].blank? ? photo_info[:filename] : photo_info[:caption]),
            :album_id => params[:album_id],
            :user_id=>current_user.id,
            :upload_batch_id => current_batch.id,            
            :source_guid => make_source_guid(photo_info[:originalurl]),
            :source_thumb_url => '/proxy?url=' + photo_info[:smallurl],
            :source_screen_url => '/proxy?url=' + photo_info[:x3largeurl]

    )
    
    ZZ::Async::GeneralImport.enqueue( photo.id, photo_info[:originalurl] )
    render :json => photo.to_json

  end

end
