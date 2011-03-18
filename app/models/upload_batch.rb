class UploadBatch < ActiveRecord::Base
  attr_accessible :album_id, :custom_order
  
  belongs_to :user
  belongs_to :album
  has_many :photos

  default_scope :order => 'created_at DESC'

  def self.get_current( user_id, album_id )
    current_batch = UploadBatch.find_by_user_id_and_album_id_and_state(user_id, album_id, 'open')
    if current_batch.nil?
      return UploadBatch.factory( user_id, album_id )
    end

    if current_batch.stale?
      current_batch.close
      return UploadBatch.factory( user_id, album_id )
    end

    return current_batch
  end


  def self.close_open_batches( user_id, album_id=nil )
    if album_id.nil?
      existing_batches = UploadBatch.find_all_by_user_id_and_state(user_id, 'open')
    else
      existing_batches = UploadBatch.find_all_by_user_id_and_album_id_and_state(user_id, album_id, 'open')
    end
    existing_batches.each { |batch|  batch.close } unless existing_batches.nil?
  end

  def self.close_stale_batches
    existing_batches = UploadBatch.find_all_by_state('open')
    existing_batches.each { |batch|  batch.close if batch.stale? } unless existing_batches.nil?
  end

  def stale?
    self.updated_at < 20.minutes.ago
  end

  # Finalize the batches that need to be set to the finished state
  # essentially this is any batch that hasn't been touched in the last
  # 20 minutes, even if they still show as open.  The only case that
  # could cause a problem is if photo processing on a batch is running
  # behind by more than 20 minutes which would cause us to close a batch
  # that could still be closed by normal means.  Maybe in the future we
  # could add support to detect that case but this should catch most
  # normal conditions
  def self.finalize_stale_batches
    expired_batches = UploadBatch.where("state <> 'finished' AND updated_at < ?", 20.minutes.ago)
    expired_batches.each do |batch|
      batch.finish(true)  # force it to finish
    end
  end

  def close
    if self.state == 'open'
      #if there are no photos in batch, destroy it
        self.state = 'closed'
        self.save 
        self.finish
    end
  end

  # returns true if we are done
  # set the force flag to true if you want to finalized regardless of the
  # current state
  def finish(force = false)
    if force || (self.state == 'closed' && self.ready?)

       #send album shares even if there were no photos uploaded
       Share.deliver_shares( self.user_id, self.album_id )

       if self.photos.count > 0
          #Notify uploader that upload batch is finished
          ZZ::Async::Email.enqueue( :photos_ready, self.id )
      
          #Create Activity
          ua = UploadActivity.create( :user => self.user, :album => self.album, :upload_batch => self )
          self.album.activities << ua

          self.state = 'finished'
          self.save
       else
          self.destroy #the batch has no photos, destroy it
       end

       # batch is done
      return true
    end

    # batch not done
    return false
  end

  protected
  def ready?
    if self.state == 'closed'
      if self.photos.count <= 0
        return true;
      end
      ready_photos = Photo.where(:upload_batch_id => self.id, :state => 'ready' ).count
#      ready_photos = Photo.find_all_by_upload_batch_id_and_state( self.id, 'ready' ).count
      return true if ready_photos == self.photos.count
    end
    return false
  end
  

  def self.factory( user_id, album_id )
    raise Exception.new( "User and Album Params must not be null for the UploadBatch factory") if( user_id.nil? or album_id.nil? )
    user = User.find( user_id )
    album = Album.find( album_id)
    nb = user.upload_batches.create({:album_id => album.id })
    if album.custom_order
      nb.custom_order_offset = album.photos.last.pos
    end
    album.upload_batches << nb
    #schedule the closing of the batch 30 minutes from now
    # TODO: If needed use resque-scheduler to close batches 30 minutes after they were open
    return nb
  end
end