module ZZ
  module Async

    class S3Upload < Base

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

#        # Add on any extra handling that your class
#        # needs - generally most classes of errors
#        # can be handled in the base class but you
#        # can special case here if needed
#        self.dont_retry_filter[RuntimeError] = /Test/i

#        # using class_inheritable_accessor our sub classes can now utilize our defaults
#        # normally you would have to define these in the subclasses these are used
#        # by the retry plugin
#        # This is just an example if we want to have a custom backoff strategy
#        def self.backoff_strategy
#         # default strategy timeouts, children should override for more specific policies
#          @backoff_strategy ||= [12.seconds, 1.minute, 5.minutes, 30.minutes, 2.hours, 8.hours, 24.hours]
#        end

        # this queue is meant to be processed only by local resque worker hence the appended host name of ourselves
        def self.queue_name(options)
          queue = Priorities.io_local_queue_name(options[:priority])
        end

        def self.enqueue( photo_id, options = {} )
          enqueue_on_queue(queue_name(options), photo_id, options)
        end
          
        def self.perform( photo_id, options = {} )
          options.recursively_symbolize_keys!
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            photo = Photo.find(photo_id)
            photo.work_priority = options[:priority]
            self.upload_to_s3(photo, options)
          end
        end

        #
        # Upload the original image to S3 from our local temp file
        # Must be prepared to deal with retries if some operation on this
        # call happens to fail since the resque worker will potential attempt
        # retires on certain failures.  Because it has the criteria for those
        # failures that will retry, it retains ownership of the temp file
        # until it determines the outcome at which point it will either hold onto
        # it for a retry or remove it if we will not be retrying.
        #
        def self.upload_to_s3(photo, options)
          begin
            photo.upload_source(options)
          rescue Exception => ex
            Rails.logger.debug("Upload to S3 Failed: " + ex)
            if self.should_retry(ex) == false
               # not going to be retrying, so safe to remove temp file
               photo.remove_source
            end
            raise ex
          end
        end

        # called on failure, will_retry tells us if we are going to
        # be trying again
        def self.handle_failure(e, will_retry, photo_id, options)
          photo = Photo.find(photo_id)
          msg = 'Upload S3: ' + e.message
          if will_retry
            photo.update_attributes(:state => 'error', :error_message => msg)
          else
            photo.update_attributes(:state => 'error_final', :error_message => msg )
          end
        end

    end
  end
end