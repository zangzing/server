module ZZ
  module Async

    class Twitter < Base
        @queue = :io_bound

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue( method, *args)
          super( method, *args)
        end

        def self.perform( method, *args )
          TwitterPublisher.send( method, *args)
        end

    end
  end
end