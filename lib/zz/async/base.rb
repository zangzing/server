module ZZ
  module Async

    # base class for resque services - holds policy for retry exceptions and timeouts
    # sub classes can override this behavior
    class Base
      @queue = nil

      class_inheritable_accessor :dont_retry_filter, :backoff_strategy, :retry_exceptions

      extend Resque::Plugins::ExponentialBackoff


      # allow async jobs to run synchronously for testing
      def self.loopback_filter=(filter)
        @@loopback_filter = filter
        @@loopback_on = !filter.nil?
      end

      def self.loopback_filter
        @@loopback_filter
      end

      # check to see if we should use loopback for this class
      def self.should_loopback?
        loopback_on? && @@loopback_filter.allow?(self)
      end

      def self.loopback_on?
        @@loopback_on ||= false
      end

      # in loopback mode we ignore errors just like a rescue job would
      # we log them however, we don't do any failure retry in this mode
      def self.do_loopback(*args)
        begin
          DeferredCompletionManager.dispatch {self.perform(*args)}
        rescue Exception => ex
          Rails.logger.error("Loopback Resque job #{self.name} failed: #{ex.message}")
        end
      end


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
      # so modifying in a subclass will not affect other subclasses
      #
      # Use the name of the exception that you want to match directly as a String
      # or the Exception class itself.  Warning, if you use the Exception class
      # directly we will consider that Exception and its subclasses to be matches
      # so use with caution
      #
      self.dont_retry_filter = {
        Exception.name                                => /^Cannot Subscribe User/i,
        BitlyError.name                               => /^MISSING_ARG/i,
        "Errno::ENOENT"                               => /.*/,
        ArgumentError.name                            => /.*/,
        NoMethodError.name                            => /.*/,
        SyntaxError.name                              => /.*/,
        NameError.name                                => /.*/,
        TypeError.name                                => /.*/,
        ActiveRecord::RecordNotFound.name             => /.*/,
        "PhotoValidationError"                        => /.*/,
        "URI::InvalidURIError"                        => /.*/,
        "Net::HTTPError"                              => /.*/,
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
        Rails.logger.info "**** PLACING ON QUEUE: #{@queue}, for #{self.name} ****"
        if should_loopback?
          self.do_loopback(*args)
        else
          Resque.enqueue( self, *args) unless loopback_on?
        end
      end

      # lets you enqueue on on a named queue
      def self.enqueue_on_queue(queue, *args)
        Rails.logger.info "**** PLACING ON QUEUE: #{queue}, for #{self.name} ****"
        if should_loopback?
          self.do_loopback(*args)
        else
          Resque::Job.create(queue, self, *args) unless loopback_on?  # when loopback_on just drop it if was not allowed
        end
      end

      def self.enqueue_in(secs_from_now, queue, *args)
        Rails.logger.info "**** PLACING ON QUEUE: #{queue}, for #{self.name} ****"
        if should_loopback?
          # delay not supported in loopback mode
          self.do_loopback(*args)
        else
          begin
            current_queue = @queue
            @queue = queue
            Resque.enqueue_in(secs_from_now, self, *args)
          rescue Exception => ex
            raise ex
          ensure
            @queue = current_queue
          end
        end
      end

      def self.try_again(*args)
        queue = Thread.current[:resque_job].queue
        if retry_delay <= 0
          # If the delay is 0, no point passing it through the scheduler
          enqueue_on_queue(queue, *args_for_retry(*args))
        else
          enqueue_in(retry_delay, queue, *args_for_retry(*args))
        end
      end

      #
      # hook into the resque retry failure mechanism
      # we want to know if we will be retrying based
      # on the exception and current state.  Pass
      # this info on to the child class in a single
      # handle_failure method that is all set up
      # with the info needed - we also wrap the call
      # in a SystemTimer and ensure that we catch
      # any exceptions coming out of the handle_failure method
      #
      def self.on_failure_retry(exception, *args)
        begin
          will_retry = retry_criteria_valid?(exception, *args)
          msg = "#{self.name} failed: #{exception}"
          Rails.logger.error(msg)
          Rails.logger.error( small_back_trace(exception))
          NewRelic::Agent.notice_error(exception, :custom_params=>{:klass_name => self.name, :method_name => 'perform', :params => args})
          SystemTimer.timeout_after(ZangZingConfig.config[:async_job_timeout]) do
            self.handle_failure(exception, will_retry, *args)
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

      # override this method if you want info about failure
      def self.handle_failure(exception, will_retry, *args)
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

      # handy helper to get at our deploy environment
      def self.env
        @@env ||= ZZDeployEnvironment.env
      end


    end
  end

end