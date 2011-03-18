module ZZ
  module Async

    class S3Upload < Base
        # this queue is meant to be processed only by local resque worker hence the appended host name of ourselves
        @queue = ("io_local_" + Server::Application.config.deploy_environment.this_host_name).to_sym

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

        def self.enqueue( photo_id )
          super( photo_id )
        end 
          
        def self.perform( photo_id )
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            photo = Photo.find(photo_id)
            self.upload_to_s3(photo)
          end
        end

        def self.on_failure_notify_photo(e, photo_id )
          begin
            SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
              photo = Photo.find(photo_id)
              photo.update_attributes(:state => 'error', :error_message => 'Failed to upload the image to S3')
            end
          rescue Exception => ex
            # eat any exception in the error handler
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
        def self.upload_to_s3(photo)
          begin
            photo.upload_source
          rescue => ex
            Rails.logger.debug("Upload to S3 Failed: " + ex)
            if self.should_retry(ex) == false
               # not going to be retrying, so safe to remove temp file
               photo.remove_source
            end
            raise ex
          end
        end
    end
  end
end