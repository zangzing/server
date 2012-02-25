class UploadBatch < ActiveRecord::Base
  attr_accessible :album_id, :for_print, :custom_order, :open_activity_at, :original_batch_created_at

  if Rails.env == "development"
    CLOSE_BATCH_INACTIVITY = 1.minutes
  else
    CLOSE_BATCH_INACTIVITY = 5.minutes
  end

  CLOSE_CALL_DEFER_TIME = 30.seconds
  FINALIZE_STALE_INACTIVITY = 1.hours
  FINALIZE_STALE_INACTIVITY_FOR_PRINT = 24.hours
  STOP_FINALIZING_TIME = 48.hours

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
            return UploadBatch.factory( user_id, album_id, false )
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
    expired_batches = UploadBatch.unscoped.where("
state <> 'finished' AND (
(updated_at < ? AND for_print IS NOT true) OR
(updated_at < ? AND for_print IS true)
)", FINALIZE_STALE_INACTIVITY.ago, FINALIZE_STALE_INACTIVITY_FOR_PRINT.ago)

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
      batch.close_immediate   # close the batch
    end
  end

  # to avoid the chance of having this close complete a batch before the agent has
  # had a chance to add any photos we don't close immediately but instead give ourselves
  # a CLOSE_CALL_DEFER_TIME window before the close can happen.  We do this by setting the last open
  # activity back in time so it only has 1 minute left before it times out
  def self.close_batch( user_id, album_id )
    batch = get_current_and_touch(user_id, album_id, false, CLOSE_BATCH_INACTIVITY - CLOSE_CALL_DEFER_TIME)
  end

  # does a safe close against a batch instance
  def close
    UploadBatch.close_batch(self.user_id, self.album_id)
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

  # NOTE: this is for internal use, a proper close is done by calling close_batch since it
  # does it in a deferred fashion.  The only time this should be called outside of this class
  # is when you know you will not be adding any more items to the batch.  Otherwise, you should
  # call the normal close which gives you a window before the close occurs.
  def close_immediate
    if self.state == 'open'
      if safe_state_change('closed')
        self.finish
      end
    end
  end


  # handy helper method useful to rspec tests
  # when you want to finish out the batch immediately
  # but not trigger notifications
  def force_finish_no_notify
    finish(true, false)
  end

  # returns true if we are done
  # set the force flag to true if you want to finalized regardless of the
  # current state
  # allow_notifications can be set to false where we do not want
  # to have any notifications triggered - this is useful for some rpsec tests
  def finish(force = false, allow_notifications = true)

    # if the batch has already finished once, dont finish it again even if photos are still pending
    return true if self.state == 'finished'

    all_ready = self.state == 'closed' && ready?
    if force || all_ready

      if safe_state_change('finished')
        album = self.album
        if album.nil?
          Rails.logger.info "Album for batch was missing, deleting batch: batch id: #{self.id}, user_id: #{self.user_id}, album_id: #{self.album_id}"
          self.destroy
          return true
        end

        # now mark the albums as ok to display since it has completed at least one batch
        album.completed_batch_count += 1
        album.save

        if self.for_print
          order = Order.find_by_number(album.name)
          return true if order.nil?
          if all_ready
            # we are a special print album and all photos are ready so notify order
            order.photos_processed
          else
            # not all photos are ready, so let the order know we gave up
            order.photos_failed
          end
          return true
        end

        # if not forced, all photos are ready, then notify
        # if forced, notify only if there are ready photos
        notify = self.photos.count > 0
        if force && all_ready == false
          notify = force_split_of_pending_photos
        end

        if allow_notifications
          #send album shares even if there were no photos uploaded
          shares.each { |share| share.deliver }

          if notify
            #Create Activity
            ua = UploadActivity.create( :user => self.user, :subject => album, :upload_batch => self )
            album.activities << ua

            #Notify UPLOADER that upload batch is finished
            ZZ::Async::Email.enqueue( :photos_ready, self.id )


            # list of user ids (as strings) and email addresses who will receive
            # album updated email
            update_notification_list = []

            # list of viewers, contributors & owner
            viewers = nil

            # add OWNER to list
            update_notification_list << album.user.id

            # add ALBUM LIKERS to list
            album.likers.each do |liker|
              update_notification_list << liker.id
            end

            # if password album, remove all users who are not
            # in ACL (these would have come from album.likers)
            if album.private?
              viewers ||= album.viewers(false)     # fetch all the viewers by id
              update_notification_list &= viewers  # filters the set of items only in both lists (i.e. filters out everyone who does not show up in the acl in one fell swoop)
            end

            # add ALBUM OWNER'S FOLLOWERS to list
            if album.public?
              album.user.followers.each do |follower|
                update_notification_list << follower.id
              end
            end

            # add CONTRIBUTOR'S FOLLOWERS  unless contributor is owner
            # removed per request by Kathryn
            #if contributor_id != owner_id
            #  self.user.followers.each do |follower|
            #    update_notification_list << follower.id
            #  end
            #end

            # for streaming album always include viewers and contributors
            if album.stream_to_email?
              viewers ||= album.viewers(false)     # fetch all the viewers by id

              if viewers.length > 0
                zza.track_event('album.stream.email')
              end

              update_notification_list |= viewers
            end


            #de-dup
            update_notification_list.uniq!


            # never send 'album updated' email to current CONTRIBUTOR
            # current contributor gets the 'photos ready' email instead
            contributor_id = self.user.id
            update_notification_list.reject! do |id|
              id == contributor_id
            end

            # SEND 'album updated' email
            update_notification_list.each do | recipient_id |
              #ZZ::Async::Email.enqueue( :album_updated, recipient_id, album_id, self.id )
              ZZ::Async::Email.enqueue( :album_updated, contributor_id, recipient_id , album_id, self.id )
            end


            # stream to facebook
            if album.stream_to_facebook?
              ZZ::Async::StreamingAlbumUpdate.enqueue_facebook_post(self.id)
              zza.track_event('album.stream.facebook')
            end

            # stream to twitter
            if album.stream_to_twitter?
              ZZ::Async::StreamingAlbumUpdate.enqueue_twitter_post(self.id)
              zza.track_event('album.stream.twitter')
            end

          else
            Rails.logger.info "Destroying empty batch id: #{self.id}, user_id: #{self.user_id}, album_id: #{self.album_id}"
            self.destroy #the batch has no photos, destroy it
          end
        end
        # batch is done
        return true
      end
    end

    # batch not done
    false
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

  # When forcing a ub to finish, pending photos are split into a new batch while ready photos remain and
  # are finished and the user notified and shares sent appropriately
  def force_split_of_pending_photos
    ready   = []
    pending = []

    self.photos.each { | p | ( p.ready? ? ready << p : pending << p ) }

    # if we have pending photos but the original batch was created too long
    # ago we finally stop trying
    if (pending.length > 0 && STOP_FINALIZING_TIME.ago < self.original_batch_created_at)
      # take the pending photos and assign them to a new batch
      # the system will take care of dealing with this new batch
      # propagate the original batch creation time so we can eventually
      # stop if we never get or process all the photos
      ub = UploadBatch.factory( self.user.id, self.album.id, self.for_print, self.original_batch_created_at, true )
      pending.each do |p|
        p.upload_batch = ub
        p.save
      end
    end

    return (ready.length > 0)
  end

  def zza
    return @zza if @zza
    @zza = ZZ::ZZA.new
    @zza.user = self.album.user.id
    @zza.user_type = 1
    @zza
  end



  # we track when the original batch was created so we can eventually stop
  # making new ones if the photos are not becoming ready after a long period
  # of time
  def self.factory( user_id, album_id, for_print, original_batch_created_at = nil, state_closed = false )
    raise Exception.new( "User and Album Params must not be null for the UploadBatch factory") if( user_id.nil? or album_id.nil? )

    user = User.find( user_id )
    album = Album.find( album_id)
    now = Time.now
    original_batch_created_at ||= now
    nb = user.upload_batches.build({:album_id => album_id, :for_print => for_print, :open_activity_at => now, :original_batch_created_at => original_batch_created_at })
    nb.state = 'closed' if state_closed
    if album.custom_order
      last_photo = album.photos.last
      nb.custom_order_offset = last_photo.pos unless last_photo.nil?
    end
    album.upload_batches << nb
    nb.save

    return nb
  end
end