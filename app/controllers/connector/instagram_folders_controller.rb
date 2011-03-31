class Connector::InstagramFoldersController < Connector::InstagramController

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
      followers = []
      SystemTimer.timeout_after(http_timeout) do
        followers = client.user_follows(nil)
      end
      root = followers.map do |f|
        {
          :name => f[:full_name], :type => 'folder', :id => "follower-#{f[:id]}",
          :open_url => instagram_photos_path(:target => f[:id]), :add_url => instagram_folder_action_path(:target => f[:id], :action => 'import')
        }
      end
    end
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(root)
  end

  def import
    photos_list = []
    SystemTimer.timeout_after(http_timeout) do
      photos_list = client.user_recent_media(feed_owner, :min_timestamp => Time.at(0), :max_timestamp => Time.now)
    end
    photos = []
    current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
    photos_list.each do |p|
      photo_url = p[:images][:standard_resolution][:url]
      photo = Photo.new_for_batch(current_batch, {
            :id => Photo.get_next_id,
            :caption => (p[:caption][:text] rescue ''),
            :album_id => params[:album_id],
            :user_id => current_user.id,
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

end
