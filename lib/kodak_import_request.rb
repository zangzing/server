class KodakImportRequest < Struct.new(:photo_id, :source_url, :auth_token)

  def perform
    kodak_connector = KodakConnector.new(auth_token)
    photo.local_image = kodak_connector.response_as_file(source_url)
    photo.save
  end

  def on_permanent_failure
    photo.update_attributes(:state => 'error', :error_mesasge => 'Failed to load photo from because of network issues')
  end

  def photo
    @photo ||= Photo.find(photo_id)
  end

end