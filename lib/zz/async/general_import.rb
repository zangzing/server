module ZZ
  module Async

    class GeneralImport < Base
      extend Resque::Plugins::Retry
      @retry_limit = 5
      @retry_delay = 10

      @queue = :io_bound
      
      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue( photo_id, source_url, options = {} )
        super( photo_id, source_url, options )
      end
      
      def self.perform( photo_id, source_url, options = {} )
        @headers = options['headers'] || {}
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          photo = Photo.find(photo_id)
          if photo.assigned? || photo.error?
            file = RemoteFile.new(source_url, PhotoGenHelper.photo_upload_dir, @headers)
            file_path = file.path
            file.close()
            file.validate_size
            photo.file_to_upload = file_path
            photo.save
          end
        end
      end

      def self.on_failure_retry(exception, *args)
        photo_id = args[0]
        photo = Photo.find(photo_id)
        if retry_criteria_valid?(exception, *args)
          photo.update_attribute(:error_message, "General Import exception: #{exception}")
          try_again(*args)
        else
          photo.update_attributes(:state => 'error', :error_message => "Failed to load photo from General Import because of network issues #{exception}" )
          Resque.redis.del(redis_retry_key(*args))
        end
      end

=begin
      def self.on_failure_notify_photo(e, photo_id, source_url )
        begin
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            photo = Photo.find(photo_id)
            photo.update_attributes(:state => 'error', :error_message => "Failed to load photo from General Import because of network issues #{e}" )
          end
        rescue Exception => ex
          # eat any exception in the error handler
        end
      end
=end

    end
  end
end
