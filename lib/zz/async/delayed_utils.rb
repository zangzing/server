module ZZ
  module Async

    class DelayedUtils < Base
      @queue = Priorities.queue_name('io', Priorities.cleanup)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue( method_name, options = {} )
        super( method_name, options )
      end

      def self.perform( method_name, options )
        options.recursively_symbolize_keys!
        SystemTimer.timeout_after( ZangZingConfig.config[:async_job_timeout] ) do
          self.send( method_name.to_sym, options )
        end
      end

      def self.delayed_destroy_album(album)
        album_id = album.id
        options = {
            :album_id => album_id
        }
        enqueue( :destroy_album, options )
      end

      # runs after queue fires
      def self.destroy_album(options)
        album_id = options[:album_id]
        Album.destroy( album_id )
      end

    end
  end
end
