class GeneralImportRequest < Struct.new(:photo_id, :source_url)

  def perform
    if photo.assigned?
      photo.local_image = RemoteFile.new(source_url)
      photo.save
    end
  end

  def on_permanent_failure
    photo.update_attributes(:state => 'error', :error_message => 'Failed to load photo from because of network issues')
  end

  def photo
    @photo ||= Photo.find(photo_id)
  end
  
end
