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
          :open_url => facebook_photos_path('me'), :add_url => nil
        }
      ]
      @folders = fb_root
    else
      album_list = facebook_graph.get(target)
      album_list.reject! { |a| a[:type] == 'profile' } #Remove 'Profile Pictures'
      unless album_list.empty?
        if album_list.first[:updated_time]
          album_list.sort!{|a, b| b[:updated_time] <=> a[:updated_time] }
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

    render :json => @folders.to_json
  end

  def import
    photos_list = facebook_graph.get("#{params[:fb_album_id]}/photos")
    photos = []
    photos_list.each do |p|
      photo = Photo.create(
                :caption => p[:name] || '',
                :album_id => params[:album_id],
                :user_id=>current_user.id,
                :source_guid => Photo.generate_source_guid(p[:source]),
                :source_thumb_url => get_photo_url(p[:id], PHOTO_SIZES[:thumb]),
                :source_screen_url => get_photo_url(p[:id], PHOTO_SIZES[:screen])
      )


      Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, p[:source]))
      photos << photo
    end


    render :json => photos.to_json
  end

end
