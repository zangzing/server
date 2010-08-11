class FacebookFoldersController < FacebookController

  def index
    album_list = facebook_graph.get('me/albums')
    album_list.reject! { |a| a[:link].include?('aid=-3') } #Remove 'Profile Pictures'

    @folders = album_list.map { |f|
      {
        :name => f[:name],
        :type => "folder",
        :id  =>  f[:id],
        :open_url => facebook_photos_path(f[:id]),
        :import_url => facebook_folder_action_path({:fb_album_id =>f[:id], :action => 'import'})
      }
    }



    respond_to do |wants|
      wants.html
      wants.json { render :json => @folders.to_json }
    end
  end

  def import
    photos_list = facebook_graph.get("#{params[:fb_album_id]}/photos")
    photos = []
    photos_list.each do |p|
      photo = Photo.create(:caption => p[:name], :album_id => params[:album_id], :user_id=>current_user.id)
      Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, p[:source]))
      photos << photo
    end

    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end


end
