module ZZ
  module Async

    class GenerateThumbnails < Base
        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.queue_name(options)
          queue = Priorities.queue_name('cpu', options[:priority])
        end

        # async edit operation
        def self.enqueue_for_edit(photo_id, queued_at_secs, response_id, options = {})
          # on amazon (zz) we will use a high priority queue
          options[:priority] ||= Priorities.photo_edit
          enqueue_on_queue(queue_name(options), photo_id, queued_at_secs, response_id, options)
        end

        def self.enqueue( photo_id, queued_at_secs, options = {} )
          enqueue_on_queue(queue_name(options), photo_id, queued_at_secs, nil, options)
        end

        # this can be for async completion if response_id is nil
        # in that case, notify the completion when we are done
        def self.perform( photo_id, queued_at_secs, response_id, options = {} )
          SystemTimer.timeout_after(ZangZingConfig.config[:thumbnail_timeout]) do
            photo = Photo.find(photo_id)
            photo.work_priority ||= options[:priority]
            if (!response_id.nil? || photo.generate_queued_at.to_i == queued_at_secs)
              # we are the latest or async so go ahead and do it
              photo.resize_and_upload
              AsyncResponse.store_response_hash(response_id, Photo.hash_one_photo(photo)) unless response_id.nil?
            else
              Rails.logger.log.warn("Photo generate request skipped due to later request pending in queue.")
            end
          end
        end

        def self.on_failure_notify_photo(e, photo_id, queued_at_secs, response_id, options = {})
          begin
            SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
              photo = Photo.find(photo_id)
              photo.update_attributes(:state => 'error', :error_message => 'Failed resize photos: ' + e.message)
            end
          rescue Exception => ex
            # eat any exception in the error handler
          ensure
            AsyncResponse.store_error(response_id, e) unless response_id.nil?
          end
        end

    end
  end
end