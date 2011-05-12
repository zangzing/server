module ZZ
  module Async

    # base class for resque services - holds policy for retry exceptions and timeouts
    # sub classes can override this behavior
    class Base
      class_inheritable_accessor :dont_retry_filter, :backoff_strategy, :retry_exceptions

      extend Resque::Plugins::ExponentialBackoff


#      # plug ourselves into the retry framework
#      # unfortunately they don't pass the instance back in
#      # so we have no frame of reference and have to use
#      # the method for this class directly
#      retry_criteria_check do |exception, *args|
#        self.should_retry exception, args
#      end


      # using class_inheritable_accessor our sub classes can no utilize our defaults
      # normally you would have to define these in the subclasses these are used
      # by the retry plugin
      def self.backoff_strategy
       # default strategy timeouts, children should override for more specific policies
        @backoff_strategy ||= [15.seconds, 1.minute, 5.minutes, 30.minutes, 2.hours, 8.hours, 24.hours]
      end

      # you need this to be an empty array if you want the
      # retry check hook to be called
      def self.retry_exceptions
        # only want to use programmatic policy to decide on retry, so clear out list
        @retry_exceptions ||= []
      end



      # define the exceptions and corresponding message pattern to match
      # if we get a match of the exception and message we will
      # not retry - this is used by the shouldRetry method to define the default
      # conditions we want to not retry for.  Modify the subclasses copy if
      # it wants to override any behavior - this is an instance per class
      # so modifying in a subclass will not effect other subclasses
      #
      # Use the name of the exception that you want to match directly as a String
      # or the Exception class itself.  Warning, if you use the Exception class
      # directly we will consider that Exception and its subclasses to be matches
      # so use with caution
      #
      self.dont_retry_filter = {
        BitlyError.name                               => /^MISSING_ARG"/i,
        "Errno::ENOENT"                               => /.*/,
        ArgumentError.name                            => /.*/,
        NoMethodError.name                            => /.*/,
        SyntaxError.name                              => /.*/,
        NameError.name                                => /.*/,
        TypeError.name                                => /.*/,
        ActiveRecord::RecordNotFound.name             => /.*/,
        "PhotoValidationError"                        => /.*/,
        "URI::InvalidURIError"                        => /.*/,
        RuntimeError.name                             => /.*/
      }


      # this method checks to see if a specific Exception should
      # retry - you should subclass this method to override the
      # default conditions - be sure to pass control onto the parent
      # with a call to super if you want the default processing to occur
      # if you are not stopping the retry from happening
      # exception - the exception that occurred
      # *args - the args to you method
      def self.should_retry(ex, *args)
        if ex
          # first see if we match by name
          # pull out the match list for the given exception name
          ex_name = ex.class.name
          ex_message = ex.message
          match = dont_retry_filter[ex_name]
          if match.nil?
            # no string match, look for an exception match
            # by scanning all explicitly since an Exception
            # can match against sub classes
            dont_retry_filter.each {|key, value|
              if (key.is_a? String) == false
                # treat as exception so subclasses match
                if key >= ex.class
                  match = value
                  break
                end
              end
            }
          end
          # if we have something to match on try it with a regular expression
          if match && (ex_message =~ match) != nil
            # when found exit with false since we don't want retry if we matched
            Rails.logger.error "Will not retry job due to matching filter exception of #{ex_name} : #{ex_message} for #{self.name}"
            return false
          end
        end

        # ok, this exception can be retried
        return true
      end


      # This method can be overrriden in a subclass to perform argument validation and then
      # called from the subclass. The idea is that this should be the only place to call
      # Resque enqueue
      def self.enqueue( *args )
        Resque.enqueue( self, *args)
      end

      # lets you enqueue on on a named queue
      def self.enqueue_on_queue(queue, *args)
        Resque::Job.create(queue, self, *args)
      end

      # resque hook to perform GC after job
      # the zz is to go last since these are
      # called in alphabetical order
      def self.after_perform_zz_gc(*args)
        #No longer needed since our photo generation flow cleans up explicitly now
        #GC.start # force gc to cleanup before we leave
      end

      # resque hook to perform GC after job
      # the zz is to go last since these are
      # called in alphabetical order
      def self.on_failure_zz_gc(*args)
        #No longer needed since our photo generation flow cleans up explicitly now
        #GC.start # force gc to cleanup before we leave
      end

    end
  end

end