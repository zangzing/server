class Connector::ZangzingPhotosController < Connector::ConnectorController

  def index
    album = current_user.albums.find(params[:zz_album_id])
    @photos = album.photos.all(:conditions=>{ :state=>'ready'}).map do |p|
      {
        :name => p.caption,
        :id   => p.id,
        :type => 'photo',
        :thumb_url => p.thumb_url,
        :screen_url => p.screen_url,
        :add_url => zangzing_photo_action_path({:photo_id => p.id, :action => 'import'}),
        :source_guid => p.source_guid
      }
    end
    render :json => JSON.fast_generate(@photos)
  end



  def import
    source_photo = current_user.albums.find(params[:zz_album_id]).photos.find(params[:photo_id])

    current_batch = UploadBatch.get_current_and_touch( current_user.id, params[:album_id] )
    photo = Photo.create(
              :id => Photo.get_next_id,
              :caption => source_photo.caption,
              :album_id => params[:album_id],
              :user_id => source_photo.user_id,
              :upload_batch_id => current_batch.id,
              :capture_date => source_photo.capture_date,
              :source_guid => source_photo.source_guid,
              :source_thumb_url => source_photo.thumb_url,
              :source_screen_url => source_photo.screen_url,
              :source => 'zangzing'
    )

    ZZ::Async::GeneralImport.enqueue( photo.id, source_photo.original_url )
    render :json => Photo.to_json_lite(photo)
  end

end
