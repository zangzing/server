class Connector::FacebookFoldersController < Connector::FacebookController

  def index
    target = params[:target]
    unless target
      fb_root = [
        {
          :name => 'My Albums', :type => 'folder', :id => 'my-albums',
          :open_url => facebook_folders_path(:target => 'me/albums'), :add_url => nil
        },
        {
          :name => 'My Friends Albums', :type => 'folder', :id => 'my-friends',
          :open_url => facebook_folders_path(:target => 'me/friends'), :add_url => nil
        },
        {
          :name => 'Photos of Me', :type => 'folder', :id => 'tagged-with-me',
          :open_url => facebook_photos_path('me'), :add_url => facebook_folder_action_path(:fb_album_id =>'me', :action => 'import')
        }
      ]
      @folders = fb_root
    else
      album_list = []
      SystemTimer.timeout_after(http_timeout) do
        album_list = facebook_graph.get(target)
      end
      album_list.reject! { |a| a[:type] == 'profile' } #Remove 'Profile Pictures'
      unless album_list.empty?
        if album_list.first[:updated_time]
          album_list.sort!{|a, b| b[:updated_time] <=> a[:updated_time] }
        end
        if target=='me/friends' #Sort by last names
          album_list = album_list.sort_by { |friend| friend[:name].split(' ').last }
        end
        @folders = album_list.map do |f|
          {
            :name => f[:name] || "Created #{f[:created_time].strftime('%d %b %Y')}",
            :type => "folder",
            :id  =>  f[:id]
          }
        end
        @folders.each do |f|
          f[:add_url] = nil
          if target=='me/friends'
            f[:open_url] = facebook_folders_path(:target => "#{f[:id]}/albums")
          elsif target.match(/\w+\/albums/)
            f[:open_url] = facebook_photos_path(f[:id])
            f[:add_url] = facebook_folder_action_path({:fb_album_id =>f[:id], :action => 'import'})
          end
        end
      else
        @folders = []
      end
    end
    expires_in 10.minutes, :public => false
    render :json => JSON.fast_generate(@folders)
  end

  def import
    photos_list = []
    SystemTimer.timeout_after(http_timeout) do
      photos_list = facebook_graph.get("#{params[:fb_album_id]}/photos")
    end
    photos = []
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )

    photos_list.each do |p|
      photo_url = get_photo_url(p, :full)
      photo = Photo.new_for_batch(current_batch, {
                :id => Photo.get_next_id,
                :user_id=>current_user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :caption => p[:name] || '',
                :capture_date => p[:created_time],
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen)
      })
      photo.temp_url = photo_url
      photos << photo
    end

    bulk_insert(photos)
  end

end
