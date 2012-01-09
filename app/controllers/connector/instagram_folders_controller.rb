class Connector::InstagramFoldersController < Connector::InstagramController
  
  def self.list_albums(api, params)
    target = params[:target]
    unless target
      call_with_error_adapter do #A call with short response just to validate token
        api.user(nil)
      end
      root = [
        {
          :name => 'My Photos', :type => 'folder', :id => 'my-photos',
          :open_url => instagram_photos_path(:target => 'my-photos', :format => 'json'), :add_url => instagram_folder_action_path(:target => 'my-photos', :action => 'import', :format => 'json')
        }
        #,
        #{
        #  :name => 'People I Follow', :type => 'folder', :id => 'i-follow',
        #  :open_url => instagram_folders_path(:target => 'i-follow', :format => 'json'), :add_url => nil
        #}
      ]
    else
      followers = call_with_error_adapter do
        api.user_follows(nil)
      end
      root = followers.map do |f|
        {
          :name => f[:full_name], :type => 'folder', :id => "follower-#{f[:id]}",
          :open_url => instagram_photos_path(:target => f[:id], :format => 'json'), :add_url => instagram_folder_action_path(:target => f[:id], :action => 'import', :format => 'json')
        }
      end
    end
    JSON.fast_generate(root)
  end
  
  def self.import_album(api, params)
    identity = params[:identity]
    photos_list = call_with_error_adapter do
      api.user_recent_media(feed_owner(params), :min_timestamp => Time.at(0), :max_timestamp => Time.now, :count => 99999)
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( identity.user.id, params[:album_id] )
    photos_list.each do |p|
      photo_url = p[:images][:standard_resolution][:url]
      photo = Photo.new_for_batch(current_batch, {
            :id => Photo.get_next_id,
            :caption => (p[:caption][:text] rescue ''),
            :album_id => params[:album_id],
            :user_id => identity.user.id,
            :upload_batch_id => current_batch.id,
            :capture_date => (Time.at(p[:created_time].to_i) rescue nil),
            :source_guid => make_source_guid(p),
            :source_thumb_url => p[:images][:thumbnail][:url],
            :source_screen_url => p[:images][:low_resolution][:url],
            :source => 'instagram'

      })

      photo.temp_url = photo_url
      photos << photo

    end

    bulk_insert(photos)
  end

  def self.import_all_albums(api_client, params)
    identity = params[:identity]
    zz_album = create_album(identity, 'My Instagram Photostream', params[:privacy])
    fire_async('import_album',  params.merge(:album_id => zz_album.id, :target => 'my-photos'))

    identity.last_import_all = Time.now
    identity.save

    JSON.fast_generate([{:album_name => zz_album.name, :album_id => zz_album.id}])
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
