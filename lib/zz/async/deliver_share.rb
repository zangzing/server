module ZZ
  module Async
    
    class DeliverShare < Base
      @queue = Priorities.queue_name('io', Priorities.deliver_share)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue( share_id )
        super( share_id )
      end  

      def self.perform( share_id )
        share = Share.find(share_id)
        share.deliver
      end

    end
    
  end
end
