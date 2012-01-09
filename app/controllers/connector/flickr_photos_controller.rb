class Connector::FlickrPhotosController < Connector::FlickrController
  
  def self.list_photos(api_client, params)
    total_pages = nil
    current_page = 0
    @photos = []
    begin
      current_page += 1
      photos_response = call_with_error_adapter do
        if params[:set_id]=='my-stream'
          api_client.people.getPhotos :user_id => 'me', :page => params[:page], :per_page => MY_STREAM_PER_PAGE, :extras => 'date_upload,original_format,url_m,url_z,url_l,url_o'
        else
          api_client.photosets.getPhotos :photoset_id => params[:set_id], :extras => 'original_format,url_m,url_z,url_l,url_o', :media => 'photos', :per_page => PHOTOSET_PAGE_SIZE, :page => current_page
        end
      end
      total_pages ||= photos_response.pages
      @photos += photos_response.photo.map do |p|
        {
          :name => p.title,
          :id   => p.id,
          :type => 'photo',
          :thumb_url =>  get_photo_url(p, :thumb),
          :screen_url =>  get_photo_url(p, :screen),
          :add_url => flickr_photo_action_path(params.merge(:photo_id =>p.id, :action => 'import', :format => 'json')),
          :source_guid => make_source_guid(p)
        }
      end
    end while current_page < total_pages
    JSON.fast_generate(@photos)
  end
  
  def self.import_photo(api_client, params)
    identity = params[:identity]
    info = nil; sizes = nil
    call_with_error_adapter do
      info = api_client.photos.getInfo :photo_id => params[:photo_id], :extras => 'url_m,url_z,url_l,url_o', :media => 'photos'
      sizes = api_client.photos.getSizes :photo_id => params[:photo_id]
    end
    photo_url = get_photo_url(sizes, :full)
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photo = Photo.create(
              :id => Photo.get_next_id,
              :user_id => identity.user.id,
              :album_id => params[:album_id],
              :upload_batch_id => current_batch.id,
              :capture_date => (DateTime.parse(info.dates.taken) rescue nil),
              :caption => info.title,
              :source_guid => make_source_guid(sizes),
              :source_thumb_url => get_photo_url(sizes, :thumb),
              :source_screen_url => get_photo_url(sizes, :screen),
              :source => 'flickr'

    )

    ZZ::Async::GeneralImport.enqueue( photo.id, photo_url )
    Photo.to_json_lite(photo)
  end

  def index
    fire_async_response('list_photos')
  end

  def import
    fire_async_response('import_photo')
  end
end
