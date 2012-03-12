module ZZ
  module Async

    class ProcessLike < Base
        @queue = Priorities.io_queue_name(Priorities.like)

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
           # Call the Like class from the empty name space :: otherwise it calls ZZ::Async::ProcessLike
           Like.send( method, *args)
        end
    end
  end
end