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

  def close
    if self.state == 'open'
      #if there are no photos in batch, destroy it
        self.state = 'closed'
        self.save 
        self.finish
    end
  end

  def finish
    if self.state == 'closed' && self.ready?

       #send album shares even if there were no photos uploaded
       Share.send_album_shares( self.user_id, self.album_id )

       if photos.length > 0
          #Notify contributor that upload batch is finished
          ZZ::Async::Email.enqueue( :upload_batch_finished, self.id )
      
          #Update album picon
          self.album.queue_update_picon

          #Create Activity
          ua = UploadActivity.create( :user => self.user, :album => self.album, :upload_batch => self )
          self.album.activities << ua

          self.state = 'finished'
          self.save
       else
          self.destroy #the batch has no photos, destroy it
      end
    end
  end

  protected
  def ready?
    if self.state == 'closed'
      if self.photos.count <= 0
        return true;
      end
      photos = Photo.find_all_by_upload_batch_id_and_state( self.id, 'ready' )
      if photos.nil?
         return true if self.photos.count <= 0
      else
         return true if photos.count == self.photos.count
      end
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