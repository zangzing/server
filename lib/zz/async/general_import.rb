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
        direct_image_url = source_url
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          photo = Photo.find(photo_id)
          if photo.assigned? || photo.error?
            # some connectors (eg dropbox) have expensive
            # calls to get the url to import. we need to do these
            # inside of resque job. so we pass 'url_making_method' callback
            # and call it here
            if options.has_key?('url_making_method')
              klass_name, method_name = options['url_making_method'].split('.')
              klass = klass_name.constantize
              direct_image_url = klass.send(method_name.to_sym, photo, source_url)
            end
            # same for headers
            if options.has_key?('headers_making_method')
              klass_name, method_name = options['headers_making_method'].split('.')
              klass = klass_name.constantize
              additional_headers = klass.send(method_name.to_sym, photo, source_url)
              @headers.merge!(additional_headers)
            end
            file_path = RemoteFile.read_remote_file(direct_image_url, PhotoGenHelper.photo_upload_dir, @headers)
            photo.file_to_upload = file_path
            photo.save
          end
        end
      end

      def self.on_failure_retry(exception, *args)
        will_retry = retry_criteria_valid?(exception, *args)
        msg = "General Import exception: #{exception}"
        Rails.logger.error(msg)
        Rails.logger.error( small_back_trace(exception))
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
