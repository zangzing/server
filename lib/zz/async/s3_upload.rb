module ZZ
  module Async

    class S3Upload < Base
        @queue = :io_bound
         
        def self.enqueue( photo_id )
          super( photo_id )
        end 
          
        def self.perform( photo_id ) 
          photo = Photo.find(photo_id) 
          photo.upload_to_s3
        end

        def self.on_failure_notify_photo(e, photo_id )
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => 'Failed to upload the image to S3')
        end
        
    end
  end
end