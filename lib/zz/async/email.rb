module ZZ
  module Async

    class Email < Base

        # only add ourselves one time
        if @retry_criteria_checks.length == 0
          # plug ourselves into the retry framework
          retry_criteria_check do |exception, *args|
            self.should_retry exception, args
          end
        end

        def self.enqueue_high( method, *args)
          enqueue_on_queue( Priorities.queue_name('io', Priorities.mailer_high), method, *args )
        end

        def self.enqueue( method, *args)
          enqueue_on_queue( Priorities.queue_name('io', Priorities.mailer), method, *args)
        end

        def self.enqueue_low( method, *args)
          enqueue_on_queue( Priorities.queue_name('io', Priorities.mailer_low), method, *args )
        end

        def self.perform( method, *args )
          begin
            msg = Notifier.send( method, *args)
            msg.deliver unless msg.nil?
          rescue SubscriptionsException => e
            Rails.logger.info e.message
          end
        end
        
    end
  end
end