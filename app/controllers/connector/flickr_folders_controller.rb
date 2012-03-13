class Connector::FlickrFoldersController < Connector::FlickrController

  def self.list_albums(api_client, params)
    if params[:my_stream]
      page_names = []

      page_num = 1
      page_count = nil
      begin
        unless page_count
          first_page = call_with_error_adapter do
            api_client.people.getPhotos :user_id => 'me', :page => page_num, :per_page => MY_STREAM_PER_PAGE, :extras => 'date_upload'
          end
          page_count = first_page.pages
        end
        page_names << "Photos #{(page_num-1)*MY_STREAM_PER_PAGE + 1} - #{page_num*MY_STREAM_PER_PAGE}"
        page_num += 1
      end while page_num <= page_count

      @folders = []
      page_names.each_with_index do |page_name, i|
        @folders << {
          :name => page_name,
          :type => "folder",
          :id => "my-stream_#{i}",
          :open_url => flickr_photos_path(:set_id => 'my-stream', :format => 'json', :page => i+1),
          :add_url => flickr_folder_action_path(:set_id => 'my-stream', :action => 'import', :format => 'json', :page => i+1)
        }
      end
    else
      folders_response = call_with_error_adapter do
        api_client.photosets.getList
      end
      @folders = folders_response.map do |f|
        {
          :name => f.title,
          :type => "folder",
          :id  =>  f.id,
          :open_url => flickr_photos_path(f.id, :format => 'json'),
          :add_url => flickr_folder_action_path(:set_id =>f.id, :action => 'import', :format => 'json')
        }
      end

      @folders.insert(0, {
        :name => 'My Photostream',
        :type => "folder",
        :id  =>  'my-stream',
        :open_url => flickr_folders_path(:format => 'json', :my_stream => true)
      })
    end
    #expires_in 10.minutes, :public => false
    JSON.fast_generate(@folders)
  end
  
  def self.import_album(api_client, params)
    identity = params[:identity]
    total_pages = nil
    current_page = 0
    photos = []
    current_batch = nil
    begin
      current_page += 1
      photo_set = call_with_error_adapter do
        if params[:set_id]=='my-stream'
          api_client.people.getPhotos :user_id => 'me', :page => params[:page], :per_page => MY_STREAM_PER_PAGE, :extras => 'date_upload,original_format,url_m,url_z,url_l,url_o'
        else
          api_client.photosets.getPhotos :photoset_id => params[:set_id], :extras => 'original_format,url_m,url_z,url_l,url_o', :media => 'photos', :per_page => PHOTOSET_PAGE_SIZE, :page => current_page
        end
      end
      total_pages ||= photo_set.pages
      current_batch ||= UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
      photo_set.photo.each do |p|
        #todo: refactor this so that flickr_folders_controller and flickr_photos_controller can share
        photo_url = get_photo_url(p, :full)
        photo_id = Photo.get_next_id
        photo = Photo.new_for_batch(current_batch, {
                  :id => photo_id,
                  :user_id => identity.user.id,
                  :album_id => params[:album_id],
                  :upload_batch_id => current_batch.id,
                  :work_priority => params[:priority] || ZZ::Async::Priorities.import_single_album,
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
    end while current_page < total_pages
    bulk_insert(photos)
  end

  def self.import_all_albums(api_client, params)
    identity = params[:identity]
    zz_albums = []
    folders_response = call_with_error_adapter do
      api_client.photosets.getList
    end
    folders_response.each do |fl_album|
      zz_album = create_album(identity, fl_album.title, params[:privacy])
      zz_albums << {:album_name => zz_album.name, :album_id => zz_album.id}
      fire_async_import_all('import_album', params.merge(:album_id => zz_album.id, :set_id => fl_album.id))
    end

    identity.last_import_all = Time.now
    identity.save


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
