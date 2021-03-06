require 'em-http'
require 'event_machine_rpc'


class AsyncAppBase < AppBase
  AsyncResponse = [-1, {}, []].freeze

  # we are being called to handle our url (/zip_download)
  def call(env)
    begin
      request_bump

      # expected to return the async body, if more_work? is true, we will kick things off
      body = dispatch_request(env)
      if body.more_work?
        # and away we go...
        body.begin_work
        # tell thin we will be doing this async
        # the real work is kicked off by the next tick
        AsyncResponse
      else
        # called with nothing to do, error
        # add logging here
        ErrorResponse
      end
    rescue Exception => ex
      # log exception
      msg = "EventMachine incoming request failed for #{env['REQUEST_PATH']} with: #{EMUtils.small_back_trace(ex, 15)}"
      logger.error(msg)
      ErrorResponse
    end
  end

end

