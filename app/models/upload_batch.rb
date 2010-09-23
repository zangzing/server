class UploadBatch < ActiveRecord::Base
  attr_accessible :album_id
  
  belongs_to :user
  belongs_to :album
  has_many :photos

  default_scope :order => 'created_at DESC'

  def self.get_current( user, album )
    current_batch = UploadBatch.find_by_user_id_and_album_id_and_state(user.id, album.id, 'open')
    if current_batch.nil?
      return UploadBatch.factory( user, album )
    end

    if current_batch.stale?
      current_batch.close
      return UploadBatch.factory( user, album )
    end

    return current_batch
  end

  def self.start_new( user,album)
    self.close_open_batches( user, album )
    return UploadBatch.factory( user, album )
  end

  def self.close_open_batches( user, album)
    existing_batches = UploadBatch.find_all_by_user_id_and_album_id_and_state(user.id, album.id, 'open')
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
    return if self.state == 'closed'
    self.state = 'closed'
    self.save
    self.finish
  end

  def ready?
    return true if self.state == 'ready'
    return false if self.state != 'closed'
    photos = Photo.find_all_by_upload_batch_id_and_state( self.id, 'ready' )
    if photos.nil?
      return false if self.photos.count > 0
      self.state = 'ready'
      self.save
      return true
    end

    if photos.count == self.photos.count
      self.state = 'ready'
      self.save
      return true;
    end
    return false;
  end

  def finish    
    return if self.state == 'finished'

    if  self.ready?
      #Notify contributor that upload batch is finished
      msg = Notifier.create_upload_batch_finished( self)
      Delayed::IoBoundJob.enqueue Delayed::PerformableMethod.new(Notifier, :deliver, [msg] )

      #If this user has any undelivered shares for this album, send them now
      shares = Share.find_all_by_user_id_and_album_id( user.id, self.id)
      shares.each { |s| s.deliver_later() } if shares

      #Update album picon
      self.album.update_picon_later

      # Create Activity
      ua = UploadActivity.create( :user => self.user, :album => self.album, :upload_batch => self )

      self.state = 'finished'
      self.save
    end
  end

  protected
  def self.factory( user, album )
    raise Exception.new( "User and Album Params must not be null for the UploadBatch factory") if( user.nil? or album.nil? )
    nb = user.upload_batches.create({:album_id => album.id})
    album.upload_batches << nb
    #schedule the closing of the batch 30 minutes from now
    Delayed::IoBoundJob.enqueue(  Delayed::PerformableMethod.new( nb, :close, {} ) , 0 ,  25.minutes.from_now  );
    return nb
  end
end