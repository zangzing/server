class Connector::ShutterflyFoldersController < Connector::ShutterflyController

  def index
    album_list = sf_api.get_albums
    folders = album_list.map { |f|
      {
        :name => f[:title].first,
        :type => 'folder',
        :id  =>  /albumid\/([0-9a-z]+)/.match(f[:id].first)[1],
        :open_url => shutterfly_photos_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id].first)[1]),
        :add_url  => shutterfly_folder_action_path(:sf_album_id => /albumid\/([0-9a-z]+)/.match(f[:id].first)[1], :action => :import)
      }
    }

    render :json => folders.to_json
  end

  def import
    photos_list = sf_api.get_images(params[:sf_album_id])
    photos = []
    photos_list.each do |p|
      photo = Photo.create(
              :caption => p[:title].first,
              :album_id => params[:album_id],
              :user_id=>current_user.id,
              :source_guid => Photo.generate_source_guid(photo_url),
              :source_thumb_url => get_photo_url(p[:id],  :thumb),
              :source_screen_url => get_photo_url(p[:id],  :screen)
      )
      Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, get_photo_url(p[:id].first, :full)))
      photos << photo
    end

    render :json => photos.to_json
  end
end
