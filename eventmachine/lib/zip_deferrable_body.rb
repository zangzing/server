require 'zz_utils'

class ZipDeferrableBody < DeferrableBodyBase

  # adds logging context in front of message
  def context_str
    str = "#{super}, album_id: #{json_data[:album_id]}"
  end

  def prepare
    self.base_zza_event = 'event_machine.zip'
    @urls = json_data[:urls]
    album_zip_name = ZZUtils.build_safe_filename(json_data[:album_name], 'zip')
    out_header = {
        'Content-Disposition' => "attachment; filename=\"#{album_zip_name}\"",
        'Content-Type' => 'application/zip',
        'Cache-Control' => 'no-cache',
        'Connection' => 'close',
    }
    # prep the zip manager
    log_info "Incoming request: #{@env.inspect}"
    zip_file_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(@urls)
    @mgr = Zip64::WriteManager.new(self, data_size)

    # if we know the final size of all photos, use the computed zip file size as the
    # content length
    if zip_file_size
      log_info "Zip content length will be: #{zip_file_size}"
      out_header['Content-Length'] = zip_file_size.to_s
    end
    out_header['ETag'] = signature if signature

    # log the info with zza
    xdata = {
        :album_name => json_data[:album_name],
        :zip_file_size => zip_file_size,
        :photo_count => @urls.count,
    }
    zza.track_transaction("#{base_zza_event}.client.start", tx_id, xdata)
    @env['async.callback'].call [200, out_header, self]
  end

  # open an http connection to the backend server
  # and process the incoming data
  def get_data_from_backend url_info
    url = url_info[:url]
    file_size = url_info[:size]

    if file_size && @mgr.need_real_bytes?(file_size) == false
      log_info "Skipping file due to seek: #{url}"
      @mgr.add_empty_bytes(file_size)
      fetch_next
      return
    end

    log_info "Fetching (#{@item_number} of #{@total_number}): #{url}"
    zza.track_transaction("#{base_zza_event}.backend.request.start", tx_id, url)

    backend_timeout = cfg[:backend_timeout]
    # uncomment the following lines and decrease the timeout to test retry handling
    #url = "http://165.23.45.99/BadBadBad" if rand(10) < 3
    #backend_timeout = 1

    # kick off the async fetch
    http = EventMachine::HttpRequest.new(url).get(:timeout => backend_timeout)
    @http = http

    # set up the async handlers
    http.headers do |h|
      connect_check do
        cant_retry
        # make sure we got a valid response
        if h.status != 200
          msg = "Failed to fetch #{url} from back end due to #{h.status} - #{h.http_reason}"
          log_error msg
          http.on_error(msg)
        else
          if @first_fetch
            @first_fetch = false
            puts h.inspect
          end

          # get info about file being downloaded
          crc32 = url_info[:crc32]
          file_size = url_info[:size]
          file_name = url_info[:filename]
          time = Time.at(url_info[:create_date]) rescue nil
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
      connect_check do
        throttle_stream(chunk)
      end
    end

    # handle any error on download
    http.errback do
      connect_check do
        # only retries if we have NOT seen
        # any response from the backend, i.e. we were
        # unable to connect.  Once data flows can't
        # retry since the zip stream would be corrupt
        if should_retry?
          # schedule another try
          EventMachine::add_timer(retry_back_off) do
            connect_check do
              log_error "Back end request retry on #{url}"
              zza.track_transaction("#{base_zza_event}.backend.request.retry", tx_id, url)
              # try again
              get_data_from_backend(url_info)
            end
          end
        else
          log_error "Back end request failed on #{url}"
          zza.track_transaction("#{base_zza_event}.backend.request.fail", tx_id, url)
          drop_client_connection
        end
      end
    end

    # called when everything is finished with current url
    http.callback do
      connect_check do
        # go get the next one or finish up
        # because we sit inside a next_tick block
        # we won't actually recurse, just get queued up
        zza.track_transaction("#{base_zza_event}.backend.request.complete", tx_id, url)
        log_info "Back end request complete on #{url}"
        fetch_next
      end
    end
  end

  # prepare to resume the stream if ready to take more data
  def check_throttle_stream
    return unless @allow_throttle
    connect_check do
      if throttle_data?
        out_size = outbound_data_size
        @high_watermark = out_size if out_size > @high_watermark
        log_info "Data stream throttled with backlog: #{out_size}, high watermark: #{@high_watermark}" if @throttle_count % 20 == 0
        @http.pause if @throttle_count == 0
        @throttle_count += 1
        current_http = @http
        EventMachine::add_timer(0.1) do
          # make sure we haven't moved on to a new http backend request
          # if it's different then we are done with the current one
          check_throttle_stream if current_http == @http
        end
      else
        if @throttle_count > 0
          # we were paused so ok to resume now
          @throttle_count = 0
          @http.resume
        end
      end
    end
  end

  # used to throttle the back end request from
  # producing more data than we can handle
  def throttle_stream(chunk)
    connect_check do
      # write the data we have been given
      @mgr.push_data(chunk)
      # now see if we should throttle
      check_throttle_stream
     end
  end

  # called only once if client connection failed
  def client_connection_failed
    @allow_throttle = false
    @http.resume
    @http.on_error("Thin client failed")
  end

  # fetch the next url in the list by pulling from the front
  def fetch_next
    # let current dispatch unwind before doing any work
    EventMachine::next_tick do
      connect_check do
        # finish out the current file
        @mgr.finish_file if @mgr.entry
        url_info = @urls.shift
        if url_info
          prep_retry
          @item_number += 1
          @throttle_count = 0
          @high_watermark = 0
          get_data_from_backend url_info
        else
          # done, finish up
          @mgr.finish_all if @mgr
          succeed
        end
      end
    end
  end

  def more_work?
    @urls && @urls.length > 0
  end

  def prep_retry
    @current_failure_count = 0
    @can_retry = true
  end

  def cant_retry
    @can_retry = false
  end

  def should_retry?
    @current_failure_count += 1
    @current_failure_count <= cfg[:max_backend_retries] && @can_retry
  end

  def doing_retry?
    @current_failure_count > 0
  end

  # exponential backoff for retry
  def retry_back_off
    @current_failure_count ** 2
  end

  def begin_work
    @allow_throttle = true
    @item_number = 0
    @total_number = @urls.length
    fetch_next
  end

  def clean_up
    log_info "Cleaned up zip data"
    @mgr.clean_up if @mgr
    @mgr = nil
    @http = nil
    super
  end
end
