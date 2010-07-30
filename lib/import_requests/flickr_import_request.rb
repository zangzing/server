class FlickrImportRequest < Struct.new(:photo_id, :source_url, :auth_token)

  def perform
    photo = Photo.find(photo_id)
    #flickr_api = Flickr.new(auth_token)
    photo.image = RemoteFile.new(source_url)
    photo.state = 'loaded' if photo.image?
    photo.save
  end


end