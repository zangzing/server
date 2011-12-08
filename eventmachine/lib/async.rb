require 'rubygems'
require 'rack'
require 'thin'
require 'em-http'
require 'json'
require 'event_machine_rpc'


class DeferrableBody
  include EventMachine::Deferrable

  attr_reader :tx_id

  # prepare for async operations by prepping data
  # with incoming env - we expect a json_path
  # query argument that has a path to a local temp
  # file containing the json
  def initialize(env)
    @env = env
    @connection = env['async.callback'].receiver  # this is a bit of hack since we are relying on the fact that async.callback comes from thins connection
    @client_peer_failure = false
    @params = Rack::Utils::parse_query(env['QUERY_STRING'])
    @json_data = (EventMachineRPC.parse_json_from_file(@params['json_path'])) rescue {}
    @user_context = @json_data[:user_context]
    @urls = @json_data[:urls]
    @chunked = more_urls?
    @first_fetch = true
    @failed = false
    @tx_id ||= rand(999999999999999)  # zza can only seem to handle 16 digits properly should handle up to BIGINT
    errback { client_peer_failed }
    callback { client_peer_success }
    # set up the zip manager
    prep_zip_manager(env)
  end

  def logger
    AsyncConfig.logger
  end

  # return the client ip from the json context
  # otherwise just the real_ip
  def user_ip
    @user_context[:user_ip] || @env['REMOTE_ADDR']
  end

  # adds logging context in front of message
  def context(msg)
    msg = "EM - ip: #{user_ip}, user_id: #{@user_context[:user_id]}, album_id: #{@json_data[:album_id]}, tx_id: #{tx_id} - #{msg}"
  end

  # protect the code block with
  # an exception handler, and drop
  # the client connection if we get an exception
  def error_wrap(&block)
    begin
      block.call
    rescue Exception => ex
      # log the error
      logger.error context("Event machine request failed: #{ex.message}")
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

  def prep_zip_manager(env)
    out_header = {
        'Content-Disposition' => "attachment; filename=\"#{@json_data[:album_name]}\"",
        'Content-Type' => 'application/zip',
        'Cache-Control' => 'no-cache',
        'Connection' => 'close',
    }
    # prep the zip manager
    logger.info context("Incoming request: #{env.inspect}")
    zip_file_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(@urls)
    @mgr = Zip64::WriteManager.new(self, data_size)

    # if we know the final size of all photos, use the computed zip file size as the
    # content length
    out_header['Content-Length'] = zip_file_size.to_s if zip_file_size
    out_header['ETag'] = signature if signature

    # send the header back to the client
    xdata = {
        :album_name => @json_data[:album_name],
        :zip_file_size => zip_file_size,
        :photo_count => @urls.count,
    }
    zza.track_transaction('event_machine.zip.client.start', tx_id, xdata)
    env['async.callback'].call [200, out_header, self]
  end

  # use i/o like interface
  def write(chunk)
    @body_callback.call(chunk)
  end

  # make us i/o like
  def close
  end

  def each &blk
    @body_callback = blk
  end

  def client_peer_success
    zza.track_transaction('event_machine.zip.client.success', tx_id)
    logger.info context("All done with multiple urls")
  end

  # This is setup in initialize via an errback handler
  # we get this if the client connection we are attached to has
  # failed.
  def client_peer_failed
    logger.error context("Got a failed connection!!!")
    @client_peer_failure = true
    zza.track_transaction('event_machine.zip.client.failed', tx_id)
    logger.error context("Client peer connection failed")
  end

  def client_failed?
    @client_peer_failure || @connection.error?
  end

  # see if client failed and if so, shut things down
  # if this is the first time in after failure
  def check_client_failed(http)
    if client_failed?
      unless @handled_failure
        # shut down the connection to the back end
        @handled_failure = true
        http.close_connection
      end
      true
    else
      false
    end
  end

  def more_urls?
    @urls && @urls.length > 0
  end

  # open an http connection to the backend server
  # and process the incoming data
  def get_data_from_backend url_info
    url = url_info[:url]
    file_size = url_info[:size]

    if file_size && @mgr.need_real_bytes?(file_size) == false
      logger.info context("Skipping file due to seek: #{url}")
      @mgr.add_empty_bytes(file_size)
      fetch_next
      return
    end

    logger.info context("Fetching: #{url}")
    zza.track_transaction('event_machine.backend.request.start', tx_id, url)

    # kick off the async fetch
    http = EventMachine::HttpRequest.new(url).get(:timeout => cfg[:backend_timeout])

    # set up the async handlers
    http.headers do |h|
      error_wrap do
        if check_client_failed(http) == false
          if @first_fetch
            @first_fetch = false
            puts h.inspect
          end

          # get info about file being downloaded
          crc32 = url_info[:crc32]
          file_size = url_info[:size]
          file_name = url_info[:filename]
          time = url_info[:create_date]
          if file_size.nil?
            # use returned length if not known
            file_size = h['CONTENT_LENGTH'].to_i
          end

          # set up the current file
          @mgr.start_file(file_name, file_size, crc32, time ? time : Time.now)
        end
      end
    end

    # pass an incoming chunk of data back to the client
    http.stream do |chunk|
      error_wrap do
        if check_client_failed(http) == false
          @mgr.push_data(chunk)
        end
      end
    end

    # handle any error on download
    http.errback do
      error_wrap do
        logger.error context("Back end request failed on #{url}: #{http.inspect}")
        zza.track_transaction('event_machine.backend.request.fail', tx_id, url)
        drop_client_connection
      end
    end

    # called when everything is finished with current url
    http.callback do
      error_wrap do
        #p http.response_header.status
        #p http.response_header
        #p http.response

        # go get the next one or finish up
        # because we sit inside a next_tick block
        # we won't actually recurse, just get queued up
        zza.track_transaction('event_machine.backend.request.complete', tx_id, url)
        fetch_next
      end
    end
  end

  # fetch the next url in the list by pulling from the front
  def fetch_next
    # let current dispatch unwind before doing any work
    EventMachine::next_tick do
      # finish out the current file
      @mgr.finish_file if @mgr.entry
      url_info = @urls.shift
      if url_info
        if client_failed?
          # the client that we are connected to went away, so stop
          # asking for data from the back end and log an error
          logger.error context("Lost client connection.  No more data will be fetched from back end.")
        else
          get_data_from_backend url_info
        end
      else
        # done, finish up
        @mgr.finish_all if @mgr
        succeed
      end
    end
  end

end

class AsyncApp
  attr_accessor :server

  # This is a template async response.
  AsyncResponse = [-1, {}, []].freeze
  ErrorResponse = [400, {}, []].freeze

  def initialize
    @request_count = 0
  end

  def request_count
    @request_count
  end

  def request_bump
    @request_count += 1
  end

  def logger
    AsyncConfig.logger
  end

  # build up some sample json data
  # used as:
  #
  # http://localhost:3001/test?json_path=/data/tmp/42903.1322105375.3002.4367048555.json
  #
  def self.make_sample_json(count)
    urls = []
    count.times do |i|
      suffix = "-%05d" % i + ".jpg"
      urls << { :url => 'http://4.zz.s3.amazonaws.com/i/df10e709-70c2-4cb1-adcd-3e20a5c35e84-o?1300228724',
                :size => 810436, :crc32 => nil, :create_date => nil,
                :filename => "file#{suffix}"}
    end
    data = {
        :user_context => {
            :user_type => 1, :user_id => 999, :user_ip => '111.111.111.111'
        },
        :album_name => 'zipper.zip',
        :album_id => 111,
        :urls => urls
    }
    EventMachineRPC.generate_json_file(data)
  end

  # we are being called to handle our url (/test)
  def call(env)
    begin
      request_bump

      body = DeferrableBody.new(env)
      if body.more_urls?
        # and away we go...
        body.fetch_next
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
      logger.error("EventMachine incoming request failed for #{env['REQUEST_PATH']} with: #{ex.message}")
      ErrorResponse
    end
  end

end

