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


            # capture the context so we can debug import issues later
            import_context = {
               :photo_id => photo_id,
               :source_url => source_url,
               :source_url_mod => direct_image_url,
               :headers => @headers,
               :options => options
            }
            photo.import_context = JSON.fast_generate(import_context)
            photo.save # if save fails for some reason, just keep going...


            # now, import the file from remote site...
            file_path = RemoteFile.read_remote_file(direct_image_url, PhotoGenHelper.photo_upload_dir, @headers)
            photo.file_to_upload = file_path
            photo.save
          end
        end
      end

      # the perform failed so take appropriate action
      def self.handle_failure(exception, will_retry, photo_id, source_url, options)
        photo = Photo.find(photo_id)
        msg = exception.message
        if will_retry
          photo.update_attributes(:error_message => msg) unless photo.nil?
        else
          unless photo.nil?
            photo.update_attributes(:state => 'error', :error_message => msg )
            z = ZZ::ZZA.new
            z.track_event("photo.import.error", {:photo_id => photo_id, :message => msg, :source => photo.source, :source_url => source_url}, 1, photo.user_id)
          end
        end
      end
    end
  end
end
