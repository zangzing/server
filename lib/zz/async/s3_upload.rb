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

# used to force failures for testing
#          raise Exception.new("testing")

          photo = Photo.find(photo_id)
          photo.upload_to_s3
          photo = nil
        end

        def self.on_failure_notify_photo(e, photo_id )
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => 'Failed to upload the image to S3')
          photo = nil
        end
        
    end
  end
end