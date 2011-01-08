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
    current_batch = UploadBatch.get_current( current_user.id, params[:album_id] )
    photos_list.each do |p|
      photo = Photo.create(
                :user_id=>current_user.id,
                :album_id => params[:album_id],
                :upload_batch_id => current_batch.id,
                :caption => p[:name] || '',
                :source_guid => make_source_guid(p),
                :source_thumb_url => get_photo_url(p, :thumb),
                :source_screen_url => get_photo_url(p, :screen)
      )

      ZZ::Async::GeneralImport.enqueue( photo.id, get_photo_url(p, :full) )
      photos << photo
    end


    render :json => photos.to_json(:only => [:id, :caption, :source_guid ] , :methods => [:stamp_url, :thumb_url, :screen_url, :original_url])
  end

end
