module ZZ
  module Async

    class KodakImport < Base
      @queue = :io_bound

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue( photo_id, source_url, auth_token )
          super( photo_id, source_url, auth_token )
      end

      def self.perform( photo_id, source_url, auth_token)
        photo = Photo.find(photo_id)
        if photo.assigned?
          kodak_connector = KodakConnector.new(auth_token)
          file = kodak_connector.response_as_file(source_url)
          file_path = file.path
          file.close()
          photo.file_to_upload = file_path
          photo.save
        end
      end

      def self.on_failure_notify_photo(e, photo_id, source_url, auth_token )
        photo = Photo.find(photo_id)
        photo.update_attributes(:state => 'error', :error_message => "Failed to load photo from because of network issues #{e}" )
      end
    end

  end
end