class GeneralImportRequest < Struct.new(:photo_id, :source_url)

  def perform
    photo = Photo.find(photo_id)
    photo.local_image = RemoteFile.new(source_url)
    photo.save
  end

end
