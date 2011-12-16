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
    self.base_zza_event ||= 'event_machine.app_not_set'
    errback { client_failed }
    callback { client_success }
    EventMachine::add_periodic_timer(10) { log_outbound_data_size if @connection }
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
    "EM - #{@env['REQUEST_PATH']}, ip: #{user_ip}, user_id: #{@user_context[:user_id]}, tx_id: #{tx_id}"
  end

  # adds logging context in front of message
  def context(msg)
    "#{context_str} - #{msg}"
  end

  # protect the code block with
  # an exception handler, and drop
  # the client connection if we get an exception
  def error_wrap(&block)
    begin
      block.call
    rescue Exception => ex
      # log the error
      log_error "Event machine request failed: #{ex.message}"
      # drop the client connection
      drop_client_connection
    end
  end

  def cfg
    AsyncConfig.config
  end

  def zza
    @zza ||= ZZ::ZZA.new
    @zza.page_uri = @env['REQUEST_PATH']
    @zza.ip_address = @user_context[:user_ip] || @env['REMOTE_ADDR']
    @zza.user_type = @user_context[:user_type] || @env['REMOTE_ADDR']
    @zza.user = @user_context[:user_id] || @env['REMOTE_ADDR']
    @zza
  end

  def drop_client_connection
    if @failed == false
      # only do it once
      @failed = true
      fail
    end
  end

  def log_outbound_data_size
    out_size = @connection.get_outbound_data_size
    log_info "OutboundDataSize is: #{out_size}"
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
    zza.track_transaction("#{base_zza_event}.client.success", tx_id)
    log_info "All requests complete."
    clean_up
  end

  # This is setup in initialize via an errback handler
  # we get this if the client connection we are attached to has
  # failed.
  def client_failed
    @client_peer_failure = true
    zza.track_transaction("#{base_zza_event}.client.failed", tx_id)
    log_error "Client peer connection failed"
  end

  def client_failed?
    @client_peer_failure || @connection.error?
  end

  # see if client failed and if so, shut things down
  # if this is the first time in after failure
  def check_client_failed
    if client_failed?
      unless @handled_failure
        # shut down the connection to the back end
        @handled_failure = true
        client_connection_failed
        clean_up
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
