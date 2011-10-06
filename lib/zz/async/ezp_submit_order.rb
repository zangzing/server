module ZZ
  module Async

    class EZPSubmitOrder < Base
      @queue = :io_bound

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      # using class_inheritable_accessor our sub classes can now utilize our defaults
      # normally you would have to define these in the subclasses these are used
      # by the retry plugin
      # This is just an example if we want to have a custom backoff strategy
      def self.backoff_strategy
       # default strategy timeouts, children should override for more specific policies
        @backoff_strategy ||= [12.seconds, 1.minute, 5.minutes, 30.minutes, 2.hours, 6.hours, 16.hours]
      end

      def self.enqueue( order_id, options = {} )
        super( order_id, options )
      end

      def self.enqueue_in( secs_from_now, order_id, options = {} )
        super( secs_from_now, @queue, order_id, options )
      end

      def self.perform( order_id, options )
        options.recursively_symbolize_keys!
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          order = Order.find(order_id)
          order.submit
        end
      end

      def self.handle_failure(exception, will_retry, order_id, options)
        if will_retry == false
          # not going to retry, we are done so notify order
          order = Order.find(order_id)
          order.ezp_submit_order_failed
        end
      end

    end
  end
end