module ZZ
  module Async

  class GeneralImport < Base
      @queue = :io_bound
      
      def self.enqueue( photo_id, source_url )
        super( photo_id, source_url )
      end
      
      def self.perform( photo_id, source_url )
        photo = Photo.find(photo_id)
        if photo.assigned?
          photo.local_image = RemoteFile.new(source_url)
          photo.save
        end
      end

      def self.on_failure_notify_photo(e, photo_id, source_url )
        logger.info "Performing #{self} failed with exception (#{e}). Dropping Job..."
        photo = Photo.find(photo_id)
        photo.update_attributes(:state => 'error', :error_message => "Failed to load photo from because of network issues #{e}" )
      end
    end
  end
end