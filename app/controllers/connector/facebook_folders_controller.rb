class Connector::FacebookFoldersController < Connector::FacebookController

  def index
    album_list = facebook_graph.get('me/albums')
    album_list.reject! { |a| a[:link].include?('aid=-3') } #Remove 'Profile Pictures'

    @folders = album_list.map { |f|
      {
        :name => f[:name],
        :type => "folder",
        :id  =>  f[:id],
        :open_url => facebook_photos_path(f[:id]),
        :add_url => facebook_folder_action_path({:fb_album_id =>f[:id], :action => 'import'})
      }
    }


    render :json => @folders.to_json
  end

  def import
    photos_list = facebook_graph.get("#{params[:fb_album_id]}/photos")
    photos = []
    photos_list.each do |p|
      photo = Photo.create(
                :caption => p[:name],
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
