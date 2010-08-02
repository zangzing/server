class KodakImportRequest < Struct.new(:photo_id, :source_url, :auth_token)

  def perform
    photo = Photo.find(photo_id)
    kodak_connector = KodakConnector.new(auth_token)
    photo.image = kodak_connector.response_as_file(source_url)
    photo.state = 'loaded' if photo.image?
    photo.save
  end


end