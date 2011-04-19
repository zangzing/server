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
    render :json => JSON.fast_generate(@folders)
  end

  def import
    photos = []
    source_photos = current_user.albums.find(params[:zz_album_id]).photos
    current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
    source_photos.each do |p|
      next unless p.ready?
      photo_url = p.original_url
      photo = Photo.new_for_batch(current_batch, {
                :id => Photo.get_next_id,
                :caption => p.caption,
                :album_id => params[:album_id],
                :user_id => p.user_id,
                :upload_batch_id => current_batch.id,                
                :capture_date => p.capture_date,
                :source_guid => p.source_guid,
                :source_thumb_url => p.thumb_url,
                :source_screen_url => p.screen_url,
                :source => 'zangzing'

      })

      photo.temp_url = photo_url
      photos << photo

    end

    Connector::ConnectorController.bulk_insert(photos)

    Photo.to_json_lite(photos)

  end
end
