module ZZ
  module Async

    class Social < Base
        #@queue decided based on service
        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( service, user_id, url, message )
          @queue = service
          super( service, user_id, url, message)
        end

        def self.perform( service, user_id, url, message )
          sender = User.find( user_id )
          bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key]).shorten( url )
          sender.send("identity_for_#{service}").post( bitly.short_url, message)
        end

    end
  end
end