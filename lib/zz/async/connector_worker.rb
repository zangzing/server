module ZZ
  module Async
      
    class ConnectorWorker < Base
      @queue = :io_bound

      # Add on any extra handling that your class
      # needs - generally most classes of errors
      # can be handled in the base class but you
      # can special case here if needed
      #
      # For the async connectors, retrying is not really useful
      # as the delay would most likely too long and the user
      # will probably retry on their own.
      #self.dont_retry_filter[Timeout::Error.name] = /.*/

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue(response_id, identity_id, klass_name, method_name, params )
        super(response_id, identity_id, klass_name, method_name, params )
      end

      def self.perform(response_id, identity_id, klass_name, method_name, params )
        SystemTimer.timeout_after(ZangZingConfig.config[:async_connector_timeout]) do
          begin
            paramz = params.symbolize_keys
            user_identity = Identity.find(identity_id)
            klass = klass_name.constantize
            api = klass.api_from_identity(user_identity)
            paramz[:identity] = user_identity
            json = klass.send(method_name.to_sym, api, paramz)
            AsyncResponse.store_response(response_id, json)
          rescue Exception => e   # this needs to be Exception if we want to also catch Timeouts
            Rails.logger.log.info exception.backtrace
            AsyncResponse.store_error(response_id, e)
          end
        end
      end

    end

  end
end