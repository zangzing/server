module ZZ
  module Async
      
    class RemoteJobWorker < Base
      def self.remote_queue_name(server)
        ("remote_job_" + server).to_sym
      end

      # job tied to a specific machine
      @queue = ZZ::Async::RemoteJobWorker.remote_queue_name(Server::Application.config.deploy_environment.this_host_name)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          false # no retries for remote jobs
        end
      end

      # put the job on our default queue
      def self.enqueue(response_id, klass_name, method_name, params )
        super(response_id, klass_name, method_name, params )
      end

      # put the job on a named queue
      def self.enqueue_on_queue(queue, response_id, klass_name, method_name, params )
        super(queue, response_id, klass_name, method_name, params )
      end

      # kick off the async portion of the rpc
      def self.remote_rpc_async(servers, klass_name, method_name, params)
        Rails.logger.info("REMOTE_RPC: #{method_name} request to #{servers.count} servers.")
        rpc_responses = []
        servers.each do |server|
          response_id = AsyncResponse.new_response_id
          rpc_response = RPCResponse.new(server, response_id)
          queue_name = remote_queue_name(server)
          Rails.logger.info("REMOTE_RPC_ENQUEUE: #{method_name} - response_id: #{response_id} to #{queue_name}")
          enqueue_on_queue(queue_name, response_id, klass_name, method_name, params)
          rpc_responses << rpc_response
        end
        rpc_responses
      end

      def self.remote_rpc_wait_results(rpc_responses)
        # ok, the work has been kicked off, time to collect the results
        # we poll with a small sleep interval while we wait.
        SystemTimer.timeout_after(ZangZingConfig.config[:remote_job_timeout]) do
          begin
            while true do
              finished = true # assume will get all results
              rpc_responses.each do |rpc_response|
                if rpc_response.complete? == false
                  # not complete, see if we have a result waiting
                  response_json = AsyncResponse.get_response(rpc_response.async_id)
                  if response_json.nil?
                    finished = false
                  else
                    # store the response
                    response = Hash.recursively_symbolize_graph!(JSON.parse(response_json))
                    rpc_response.response = response
                    if response[:exception]
                      # we have an error, so record the info
                      rpc_response.error_code = response[:code]
                      rpc_response.error_message = response[:message]
                    else
                      rpc_response.error_code = 0
                      rpc_response.error_message = ""
                    end
                  end
                end
              end
              break if finished
              # not finished, sleep for a brief period then check again
              sleep(0.3)
            end
          rescue Exception => ex   # eat the exception, we will have incomplete results to indicate failure
          end
        end
        return rpc_responses
      end

      # Put the job on all the server remote queues, and wait for the results.
      # Returns an array of async responses.  The async responses can
      # be returned in a non complete state if we get a timeout while waiting
      # you can check for valid results by calling the .complete? method
      # on the individual rpc responses.
      def self.remote_rpc(servers, klass_name, method_name, params)
        # first start the async work
        rpc_responses = remote_rpc_async(servers, klass_name, method_name, params)
        return remote_rpc_wait_results(rpc_responses)
      end

      # put the job on all the app server remote queues, and wait for the results
      # returns an array of async responses
      def self.remote_rpc_app_servers(klass_name, method_name, params)
        app_servers = Server::Application.config.deploy_environment.all_app_servers
        remote_rpc(app_servers, klass_name, method_name, params)
      end

      # put the job on all the app server remote queues, does not wait for a result
      def self.remote_rpc_app_servers_async(klass_name, method_name, params)
        app_servers = Server::Application.config.deploy_environment.all_app_servers
        remote_rpc_async(app_servers, klass_name, method_name, params)
      end


      def self.perform(response_id, klass_name, method_name, params )
        SystemTimer.timeout_after(ZangZingConfig.config[:remote_job_timeout]) do
          begin
            paramz = params.symbolize_keys
            klass = klass_name.constantize
            result = klass.send(method_name.to_sym, paramz)
            json = JSON.fast_generate(result)
            Rails.logger.info("REMOTE_RPC_PERFORM: #{method_name} - successful, response_id: #{response_id}")
            AsyncResponse.store_response(response_id, json)
          rescue Exception => e   # this needs to be Exception if we want to also catch Timeouts
            Rails.logger.error("REMOTE_RPC_PERFORM: #{method_name} - failed, response_id: #{response_id} with #{e.message}")
            AsyncResponse.store_error(response_id, e)
          end
        end
      end

    end

  end
end