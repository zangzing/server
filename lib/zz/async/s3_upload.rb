module ZZ
  module Async

    class S3Upload < Base
        @queue = :io_bound
         
        def self.enqueue( photo_id )
          super( photo_id )
        end 
          
        def self.perform( photo_id )
#GWS more debug code
msg = "Processing incoming photo upload in resque task"
puts msg
Rails.logger.info msg
          begin
            photo = Photo.find(photo_id)
            photo.upload_to_s3
          rescue => ex
  #GWS more debug code
  msg = ex.backtrace.to_s
  puts msg
  Rails.logger.info msg
            raise ex
          end
        end

        def self.on_failure_notify_photo(e, photo_id )
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => 'Failed to upload the image to S3')
        end
        
    end
  end
end