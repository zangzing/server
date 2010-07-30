class FacebookImportRequest < Struct.new(:photo_id, :source_url)

  def perform
    photo = Photo.find(photo_id)
    photo.image = RemoteFile.new(source_url)
    photo.state = 'loaded' if photo.image?
    photo.save
  end

end
