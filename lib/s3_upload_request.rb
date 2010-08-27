class S3UploadRequest < Struct.new(:photo_id)

  def perform
    photo.upload_to_s3
  end

  def on_permanent_failure
    photo.update_attributes(:state => 'error', :error_mesasge => 'Failed to upload the image to S3')
  end

  def photo
    @photo ||= Photo.find(photo_id)
  end

end