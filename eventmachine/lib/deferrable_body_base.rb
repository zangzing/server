require 'em-http'
require 'event_machine_rpc'

class DeferrableBodyBase
  include EventMachine::Deferrable

  attr_accessor :base_zza_event
  attr_reader :tx_id, :json_data

  # prepare for async operations by prepping data
  # with incoming env - we expect a json_path
  # query argument that has a path to a local temp
  # file containing the json
  def initialize(env, json_data)
    @env = env
    @connection = env['async.callback'].receiver  # this is a bit of hack since we are relying on the fact that async.callback comes from thins connection
    @client_peer_failure = false
    @json_data = json_data
    @user_context = @json_data[:user_context]
    @first_fetch = true
    @failed = false
    @tx_id ||= rand(999999999999999)  # zza can only seem to handle 16 digits properly should handle up to BIGINT
    @back_end_dropped_client = false
    @handled_failure = false
    self.base_zza_event ||= 'event_machine.app_not_set'
    errback { client_failed }
    callback { client_success }
    prepare
  end

  # prepare to start working
  def prepare
  end

  def logger
    AsyncConfig.logger
  end

  def log_debug(msg)
    logger.debug context(msg)
  end

  def log_info(msg)
    logger.info context(msg)
  end

  def log_error(msg)
    logger.error context(msg)
  end

  # return the client ip from the json context
  # otherwise just the real_ip
  def user_ip
    @user_context[:user_ip] || @env['REMOTE_ADDR']
  end

  # child class should call this and append its own data
  def context_str
    begin
      msg = "EM - #{@env['REQUEST_PATH']}, ip: #{user_ip}, user_id: #{@user_context[:user_id]}, tx_id: #{tx_id}"
    rescue Exception => ex
      msg = "EM - Logging Context Exception: #{ex.message}"
    end
    msg
  end

  # adds logging context in front of message
  def context(msg)
    "#{context_str} - #{msg}"
  end

  # protect the code block with
  # an exception handler, and drop
  # the client connection if we get an exception
  # also makes sure client side is still connected
  def connect_check(&block)
    begin
      if check_client_failed == false
        block.call
      end
    rescue Exception => ex
      # log the error
      log_error "Event machine unexpected exception, request failed: #{ex.message}"
      # drop the client connection
      drop_client_connection rescue nil
    end
  end

  def cfg
    AsyncConfig.config
  end

  def zza
    @zza ||= ZZ::ZZA.new
    @zza.page_uri = @env['REQUEST_PATH']
    @zza.ip_address = @user_context[:user_ip] || @env['REMOTE_ADDR']
    @zza.user_type = @user_context[:user_type]
    @zza.user = @user_context[:user_id]
    @zza
  end

  def drop_client_connection
    if @failed == false
      # only do it once
      @failed = true
      @back_end_dropped_client = true
      fail
    end
  end

  # Limit where we throttle data
  # we do this by pausing EM for
  # the current backend connection
  # until we get back below the limit
  def throttle_limit
    @throttle_limit ||= 128 * 1024
  end

  def throttle_data?
    outbound_data_size > throttle_limit
  end

  def outbound_data_size
    @connection ? @connection.get_outbound_data_size : 0
  end

  def log_outbound_data_size
    log_info "OutboundDataSize is: #{outbound_data_size}"
  end

  # use i/o like interface
  def write(chunk)
    @body_callback.call(chunk)
  end

  # make us i/o like
  def close
  end

  # called from deferrable body
  def each &blk
    @body_callback = blk
  end

  def client_success
    connect_check do
      begin
        zza.track_transaction("#{base_zza_event}.client.success", tx_id)
        log_info "All requests complete."
      ensure
        clean_up
      end
    end
  end

  # This is setup in initialize via an errback handler
  # we get this if the client connection we are attached to has
  # failed.
  def client_failed
    @client_peer_failure = true
    zza.track_transaction("#{base_zza_event}.client.failed", tx_id)
    msg = @back_end_dropped_client ? "Back end dropped client connection" : "Unexpected client disconnect"
    log_error msg
    check_client_failed # kick off cleanup
  end

  def client_failed?
    @client_peer_failure || @connection.nil? || @connection.error?
  end

  # see if client failed and if so, shut things down
  # if this is the first time in after failure
  def check_client_failed
    if client_failed?
      unless @handled_failure
        # shut down the connection to the back end
        @handled_failure = true
        # schedule the cleanup to happen shortly
        EventMachine::next_tick do
          client_connection_failed rescue nil
          clean_up rescue nil
        end
      end
      true
    else
      false
    end
  end

  # called only once if client connection failed
  def client_connection_failed
  end

  # override and return true if more fetching to do
  def more_work?
    false
  end

  # override this to kick off the work
  def begin_work
  end

  def clean_up
    @connection = nil
    @env = nil
  end
end

