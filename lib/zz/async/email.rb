module ZZ
  module Async

    class Email < Base
        @queue = :mailer
        
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
          if defined?(Rails.version) && Rails.version.to_i >= 3
            Notifier.send( method, *args).deliver
            #ZZ::MailChimp::Notifier.send( method, *args).deliver
          else
            Notifier.send('deliver_'+method, *args)
          end
        end
        
    end
  end
end