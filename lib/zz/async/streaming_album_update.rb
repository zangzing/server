module ZZ
  module Async

    class StreamingAlbumUpdate < Base
      @queue = Priorities.queue_name('io', Priorities.streaming_album_update)

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end




        def self.enqueue_facebook_post( batch_id)
          self.enqueue( 'facebook', batch_id)
        end

        def self.enqueue_twitter_post( batch_id)
          self.enqueue( 'twitter', batch_id)
        end

        def self.perform( service, batch_id )
          batch = UploadBatch.find(batch_id)
          album = batch.album
          user = album.user

          case service
            when 'twitter'
              user.identity_for_twitter.post_streaming_album_update(batch)

            when 'facebook'
              user.identity_for_facebook.post_streaming_album_update(batch)

          end
       end
    end
  end
end
