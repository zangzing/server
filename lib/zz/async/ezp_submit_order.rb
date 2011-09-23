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

      def self.perform( order_id, options )
        SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
          order = Order.find(order_id)
          order.ezp_submit_order
        end
      end

      def self.on_failure_retry(exception, *args)
        will_retry = retry_criteria_valid?(exception, *args)
        msg = "EZPSubmitOrder failed: #{exception}"
        Rails.logger.error(msg)
        Rails.logger.error( small_back_trace(exception))
        NewRelic::Agent.notice_error(exception, :custom_params=>{:klass_name => self.name, :method_name => 'perform', :params => args})
        begin
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            order_id = args[0]
            options = args[1]
            order = Order.find(order_id)
            if will_retry
              # ignore the retry case since we will have another chance
            else
              order.ezp_submit_order_failed
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