module ZZ
  module Async

    class GenerateThumbnails < Base
        @queue = :image_processing

        def self.enqueue( photo_id )
          super( photo_id )
        end

        def self.perform( photo_id )
          photo = Photo.find(photo_id)
          photo.generate_thumbnails
        end

        def self.on_failure_notify_photo(e, photo_id )
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => 'Failed to Generate Thumbnails')
        end

    end
  end
end