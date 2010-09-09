class Connector::ZangzingFoldersController < Connector::ConnectorController

  def index
    @folders = current_user.albums.map { |f|
      {
        :name => f.name,
        :type => "folder",
        :id  => f.id,
        :open_url => zangzing_photos_path(f.id),
        :add_url => zangzing_folder_action_path({:zz_album_id =>f.id, :action => 'import'})
      }
    }


    render :json => @folders.to_json
  end

  def import
    photos = []
    current_user.albums.find_by_id(params[:zz_album_id]).photos.each do |p|
      photo = Photo.create(
                :caption => p.caption,
                :album_id => params[:album_id],
                :user_id => p.user_id,
                :source_guid => p.source_guid,
                :source_thumb_url => p.source_thumb_url,
                :source_screen_url => p.source_screen_url
      )

      #Delayed::IoBoundJob.enqueue(ZzCopyRequest.new(photo.id, p.id))
      Delayed::IoBoundJob.enqueue(GeneralImportRequest.new(photo.id, p.image.url))
      photos << photo
    end


    render :json => photos.to_json
  end
end
