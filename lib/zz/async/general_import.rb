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

      def self.enqueue( photo_id, source_url, options = {} )
        super( photo_id, source_url, options )
      end
      
      def self.perform( photo_id, source_url, options = {} )
        @headers = options['headers'] || {}
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          photo = Photo.find(photo_id)
          if photo.assigned? || photo.error?
            file_path = RemoteFile.read_remote_file(source_url, PhotoGenHelper.photo_upload_dir, @headers)
            photo.file_to_upload = file_path
            photo.save
          end
        end
      end

      def self.on_failure_retry(exception, *args)
        will_retry = retry_criteria_valid?(exception, *args)
        msg = "General Import exception: #{exception}"
        Rails.logger.error(msg)
        NewRelic::Agent.notice_error(exception, :custom_params=>{:klass_name => ZZ::Async::GeneralImport.name, :method_name => 'perform', :params => args})
        begin
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            photo_id = args[0]
            photo = Photo.find(photo_id)
            if will_retry
              photo.update_attributes(:error_message => msg) unless photo.nil?
            else
              photo.update_attributes(:state => 'error', :error_message => msg ) unless photo.nil?
            end
          end
        rescue Exception => ex
          # don't let the exception make it out
        end
        if will_retry
          try_again(*args)
        else
          Resque.redis.del(redis_retry_key(*args))
        end
      end

    end
  end
end
