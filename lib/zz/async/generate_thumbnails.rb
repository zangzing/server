module ZZ
  module Async

    class GenerateThumbnails < Base
        @queue = :image_processing

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( photo_id, queued_at_secs )
          super( photo_id, queued_at_secs )
        end

        def self.perform( photo_id, queued_at_secs )
          photo = Photo.find(photo_id)
          if (photo.generate_queued_at.to_i == queued_at_secs)
            # we are the latest so go ahead and do it
            photo.resize_and_upload
          else
            Rails.logger.log.warn("Photo generate request skipped due to later request pending in queue.")
          end
        end

        def self.on_failure_notify_photo(e, photo_id, queued_at_secs)
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => 'Failed to resize photos')
        end

    end
  end
end