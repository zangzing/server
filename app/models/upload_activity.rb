#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class UploadActivity < Activity
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

  def payload_valid?
    begin
      return true if upload_batch
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def display_for?( current_user, view )
    return true if upload_batch.album.public?
    return true if view == ALBUM_VIEW && upload_batch.album.hidden?
    return true if current_user && upload_batch.album.viewer?( current_user.id )
    false
  end
  
end
