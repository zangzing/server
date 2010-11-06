module ZZ
  module Async

    class Email < Base
        @queue = :mailer
        
        def self.enqueue( method, *args)
          super( method, *args)
        end
        
        def self.perform( method, *args ) 
          if defined?(Rails.version) && Rails.version.to_i >= 3
            Notifier.send( method, *args).deliver
          else
            Notifier.send('deliver_'+method, *args)
          end
        end
        
    end
  end
end