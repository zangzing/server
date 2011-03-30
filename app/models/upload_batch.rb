class UploadBatch < ActiveRecord::Base
  attr_accessible :album_id, :custom_order, :open_activity_at

  CLOSE_BATCH_INACTIVITY = 5.minutes
  CLOSE_CALL_DEFER_TIME = 30.seconds
  FINALIZE_STALE_INACTIVITY = 24.hours

  belongs_to :user
  belongs_to :album
  has_many   :photos
  has_many   :shares

  # efficient update of open activity and updated_at
  # does immediate update
  def self.touch_open_activity(batch_id)
    now = Time.now
    UploadBatch.update(batch_id, :open_activity_at => now, :updated_at => now)
  end

  def self.get_current_and_touch( user_id, album_id, new_if_not_found = true, back_date_offset = 0 )
    # since this is an optimistic lock it is possible that someone
    # else sneaks in.  If so we get an exception telling us the update
    # was stale so we will keep trying till no longer stale
    #
    # we use the optimistic locking model to make sure that in the very
    # small window where we've found a batch in the open state that
    # no one else sneaks in and changes the state on us to closed.
    # If that happens, we try again and would return a new batch if
    # a close occurred, or the same batch if it was caused by some other
    # process fetching it.
    #
    # Once we get the object it will be safe for at least 5 more minutes (our batch close interval)
    # because as part of obtaining the object we update the open_activity_at time.
    #
    #
    # if new_if_not_found is set we will create a new one if not found otherwise we return nil
    #
    # back_date_offset tells us how much if any offset to subtract from now to show activity in the
    # past.  This is useful for cases like close not really closing but setting up the sweeper to
    # time out and close in the near future.
    #
    current_batch = nil
    try_again = true
    while try_again do
      begin
        try_again = false # assume we will get it
        current_batch = UploadBatch.find_by_user_id_and_album_id_and_state(user_id, album_id, 'open')

        if current_batch.nil?
          if new_if_not_found
            return UploadBatch.factory( user_id, album_id )
          end
          return nil
        end

        current_batch.open_activity_at = Time.now - back_date_offset
        current_batch.save
      rescue ActiveRecord::StaleObjectError => ex
        # need to try again
        try_again = true
      rescue Exception => ex
        # any other type of exception means we did not get
        # our range so invalidate it and reraise the exception
        raise ex
      end
    end

    return current_batch
  end

  # Finalize the batches that need to be set to the finished state
  # essentially this is any batch that hasn't been touched in the last
  # 24 hours, even if they still show as open.  The only case that
  # could cause a problem is if photo processing on a batch is running
  # behind by more than 24 hours which would cause us to close a batch
  # that could still be closed by normal means.  The consequences in this
  # rare case are that emails may go out on an incomplete album
  def self.finalize_stale_batches
    expired_batches = UploadBatch.unscoped.where("state <> 'finished' AND updated_at < ?", FINALIZE_STALE_INACTIVITY.ago)
    expired_batches.each do |batch|
      batch.finish(true)  # force it to finish
    end
  end

  # Close any batches that have been sitting without any open activity for 5 minutes.  This gives the
  # user the chance to add to the batch for a period of time before we close it.  Each time something
  # is added the timer is reset and the window extends again.  Once in the
  # closed state if there was any remaining photo activity to be done the last ready photo
  # will finalize the batch.  If for some reason the photos are not ready within 24 hours
  # we clean up everything in the finalize_stale_batches method.
  def self.close_pending_batches
    expired_batches = UploadBatch.unscoped.where("state = 'open' AND open_activity_at < ?", CLOSE_BATCH_INACTIVITY.ago)
    expired_batches.each do |batch|
      batch.close_internal   # close the batch
    end
  end

  # to avoid the chance of having this close complete a batch before the agent has
  # had a chance to add any photos we don't close immediately but instead give ourselves
  # a CLOSE_CALL_DEFER_TIME window before the close can happen.  We do this by setting the last open
  # activity back in time so it only has 1 minute left before it times out
  def self.close_open_batch( user_id, album_id )
    batch = get_current_and_touch(user_id, album_id, false, CLOSE_BATCH_INACTIVITY - CLOSE_CALL_DEFER_TIME)
  end


  # consumes the stale error and returns true
  # only if we can change state
  def safe_state_change(state)
    begin
      # immediately mark new state
      # if somebody else snuck in and grabbed it
      # as an open object then the update will fail
      # as stale.  In that case just ignore this one
      self.state = state
      self.save
    rescue ActiveRecord::StaleObjectError => ex
      # eat exception but indicate state did not change
      return false
    rescue Exception => ex
      # any other type of exception means we did not get
      # our range so invalidate it and reraise the exception
      raise ex
    end

    return true
  end

  # NOTE: this is for internal use, a proper close is done by calling close_open_batch since it
  # does it in a deferred fashion.
  def close_internal
    if self.state == 'open'
      if safe_state_change('closed')
        self.finish_internal
      end
    end
  end

  # returns true if we are done
  # set the force flag to true if you want to finalized regardless of the
  # current state
  def finish_internal(force = false)

    # if the batch has already finished once, dont finish it again even if photos
    return true if self.state == 'finished'

    if force || (self.state == 'closed' && self.ready?)

       if safe_state_change('finished')
         #send album shares even if there were no photos uploaded
         shares.each { |share| share.deliver }

         # now mark the albums as ok to display since it has completed at least one batch
         album = self.album
         album.completed_batch_count += 1
         album.save

         if self.photos.count > 0
            #Create Activity
            ua = UploadActivity.create( :user => self.user, :album => album, :upload_batch => self )
            album.activities << ua

            #Notify uploader that upload batch is finished
            ZZ::Async::Email.enqueue( :photos_ready, self.id )

            #Notify likers that there is new activity in this album
            album_id = album.id
            self.album.likers.each do |liker|
              ZZ::Async::Email.enqueue( :album_updated, liker.id, album_id )
            end
         else
            Rails.logger.info "Destroying empty batch id: #{self.id}, user_id: #{self.user_id}, album_id: #{self.album_id}"
            self.destroy #the batch has no photos, destroy it
         end

         # batch is done
         return true
      end
    end

    # batch not done
    return false
  end

  protected
  def ready?
    if self.state == 'closed'
      batch_photo_count = self.photos.count
      if batch_photo_count <= 0
        return true;
      end
      ready_photo_count = Photo.where(:upload_batch_id => self.id, :state => 'ready' ).count
      return true if ready_photo_count == batch_photo_count
    end
    return false
  end
  

  def self.factory( user_id, album_id )
    raise Exception.new( "User and Album Params must not be null for the UploadBatch factory") if( user_id.nil? or album_id.nil? )

    user = User.find( user_id )
    album = Album.find( album_id)
    now = Time.now
    nb = user.upload_batches.build({:album_id => album.id, :open_activity_at => now })
    if album.custom_order
      nb.custom_order_offset = album.photos.last.pos
    end
    album.upload_batches << nb
    nb.save

    return nb
  end
end