class KodakImportRequest < Struct.new(:photo_id, :source_url, :auth_token)

  def perform
    photo = Photo.find(photo_id)
    kodak_connector = KodakConnector.new(auth_token)
    photo.local_image = kodak_connector.response_as_file(source_url)
    photo.save
  end

end