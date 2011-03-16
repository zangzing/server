module ZZ
  module Async

  class GeneralImport < Base
      @queue = :io_bound
      
      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue( photo_id, source_url )
        super( photo_id, source_url )
      end
      
      def self.perform( photo_id, source_url )
        photo = Photo.find(photo_id)
        if photo.assigned?
          file = RemoteFile.new(source_url, PhotoGenHelper.photo_upload_dir)
          file_path = file.path
          file.close()
          photo.file_to_upload = file_path
          photo.save
        end
      end

      def self.on_failure_notify_photo(e, photo_id, source_url )
        begin
          photo = Photo.find(photo_id)
          photo.update_attributes(:state => 'error', :error_message => "Failed to load photo from General Import because of network issues #{e}" )
        rescue Exception => ex
          # eat any exception in the error handler
        end
      end
    end
  end
end