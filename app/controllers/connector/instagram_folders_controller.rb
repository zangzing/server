class Connector::InstagramFoldersController < Connector::InstagramController
  
  def self.list_albums(api, params)
    followers = api.user_follows(nil)
    root = followers.map do |f|
      {
        :name => f[:full_name], :type => 'folder', :id => "follower-#{f[:id]}",
        :open_url => instagram_photos_path(params.merge(:target => f[:id])), :add_url => instagram_folder_action_path(params.merge(:target => f[:id], :action => 'import'))
      }
    end
    JSON.fast_generate(root)
  end
  
  def self.import_album(api, params)
    identity = params[:identity]
    photos_list = api.user_recent_media(feed_owner(params), :min_timestamp => Time.at(0), :max_timestamp => Time.now)
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

  def index
    target = params[:target]
    unless target
      root = [
        {
          :name => 'My Photos', :type => 'folder', :id => 'my-photos',
          :open_url => instagram_photos_path(:target => 'my-photos'), :add_url => instagram_folder_action_path(:target => 'my-photos', :action => 'import')
        },
        {
          :name => 'People I Follow', :type => 'folder', :id => 'i-follow',
          :open_url => instagram_folders_path(:target => 'i-follow'), :add_url => nil
        }
      ]
    else
      fire_async_response('list_albums')
      return
    end
    #expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(root)
  end

  def import
    fire_async_response('import_album')
  end

end
