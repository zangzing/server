module ZZ
  module Async
      
    class ConnectorWorker < Base

      @queue = :io_bound

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
            params.symbolize_keys!
            user_identity = Identity.find(identity_id)
            klass = klass_name.constantize
            api = klass.api_from_identity(user_identity)
            params[:identity] = user_identity
            json = klass.send(method_name.to_sym, api, params)
            AsyncResponse.store_response(response_id, json)
          rescue => e
            if Connector::ConnectorController.classify_exception(e)
              AsyncResponse.store_error(response_id, e)
            else
              raise e
            end
          end
        end
      end

    end

  end
end