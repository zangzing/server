module ZZ
  module Async

    class Facebook < Base
        @queue = Priorities.queue_name('io', Priorities.facebook)

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
          FacebookPublisher.send( method, *args)
        end

    end
  end
end