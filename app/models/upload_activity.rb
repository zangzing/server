class UploadActivity < AlbumActivity
  attr_accessible :upload_batch
  validates_presence_of :upload_batch

  # The payload is the upload batch id

  before_save :save_batch_id

  def save_batch_id
    self.payload = @upload_batch.id
  end

  def upload_batch
    @upload_batch ||= UploadBatch.find( self.payload )    
  end

  def upload_batch=( ub )
    if ub.is_a?(UploadBatch)
      @upload_batch = ub
    else
      raise new Exception("Argument must be UploadBatch");
    end
  end
end
