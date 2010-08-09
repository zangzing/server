class ShutterflyPhotosController < ShutterflyController
require 'pp'
  def index
    photos_list = sf_api.get_images(params[:sf_album_id])
    photos = photos_list.map { |p| {:name => p[:title].first, :id => p[:id].first } }
    respond_to do |wants|
      wants.html { @photos = photos }
      wants.json { render :json => photos.to_json }
    end
  end

  def show
    photo_url = get_photo_url(params[:photo_id], (params[:size] || :screen).to_sym)
    bin_io = OpenURI.send(:open, photo_url)
    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
  end

  def import
    photos_list = sf_api.get_images(params[:sf_album_id])
    photo_title = photos_list.select { |p| p[:id].first==params[:photo_id] }.first[:title].first
    photo_url = get_photo_url(params[:photo_id], (params[:size] || :screen).to_sym)
    photo = Photo.create(:caption => photo_title, :album_id => params[:album_id])
    Delayed::Job.enqueue(GeneralImportRequest.new(photo.id, photo_url))
    respond_to do |wants|
      wants.html { @photo = photo }
      wants.json { render :json => photo.to_json }
    end
  end

end
