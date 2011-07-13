class Connector::FlickrFoldersController < Connector::FlickrController

  def self.list_albums(api_client, params)
    folders_response = call_with_error_adapter do
      api_client.photosets.getList
    end
    @folders = folders_response.map { |f|
      {
        :name => f.title,
        :type => "folder",
        :id  =>  f.id,
        :open_url => flickr_photos_path(f.id, :format => 'json'),
        :add_url => flickr_folder_action_path(:set_id =>f.id, :action => 'import', :format => 'json')
      }
    }
    #expires_in 10.minutes, :public => false
    JSON.fast_generate(@folders)
  end
  
  def self.import_album(api_client, params)
    identity = params[:identity]
    photo_set = call_with_error_adapter do
      api_client.photosets.getPhotos :photoset_id => params[:set_id], :extras => 'original_format,url_m,url_z,url_l,url_o', :media => 'photos'
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo_set.photo.each do |p|
      #todo: refactor this so that flickr_folders_controller and flickr_photos_controller can share
      photo_url = get_photo_url(p, :full)
      photo_id = Photo.get_next_id
      photo = Photo.new_for_batch(current_batch, {
                :id => photo_id,
                :user_id => identity.user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :capture_date => (DateTime.parse(p.datetaken) rescue nil),
                :caption => p.title,
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen),
                :source => 'flickr'

      })

      photo.temp_url = photo_url
      photos << photo
    end

    bulk_insert(photos)
  end

  def self.import_all_albums(api_client, params)
    identity = params[:identity]
    zz_albums = []
    folders_response = call_with_error_adapter do
      api_client.photosets.getList
    end
    unless folders_response.empty?
      folders_response.each do |fl_album|
        zz_album = create_album(identity, fl_album.title)
        photos = import_folder(api_client, params.merge(:album_id => zz_album.id, :set_id => fl_album.id))
        zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id, :photos => photos}

      end
    end
    JSON.fast_generate(zz_albums)
  end


  def index
    fire_async_response('list_albums')
  end
  
  def import
    fire_async_response('import_album')
  end

  def import_all
    fire_async_response('import_all_albums')
  end
end
