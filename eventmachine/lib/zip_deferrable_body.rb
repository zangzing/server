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
#        'Cache-Control' => 'no-cache',
#        'Connection' => 'close',
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

    # send the header back to the client
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

    # kick off the async fetch
    http = EventMachine::HttpRequest.new(url).get(:timeout => cfg[:backend_timeout])
    @http = http
    @item_number += 1

    # set up the async handlers
    http.headers do |h|
      error_wrap do
        # make sure we got a valid response
        if check_client_failed == false
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
    end

    # pass an incoming chunk of data back to the client
    http.stream do |chunk|
      error_wrap do
        if check_client_failed == false
          @mgr.push_data(chunk)
        end
      end
    end

    # handle any error on download
    http.errback do
      error_wrap do
        if client_failed? == false
          log_error "Back end request failed on #{url}: #{@http.inspect}"
          zza.track_transaction("#{base_zza_event}.backend.request.fail", tx_id, url)
          drop_client_connection
        end
      end
    end

    # called when everything is finished with current url
    http.callback do
      error_wrap do
        # go get the next one or finish up
        # because we sit inside a next_tick block
        # we won't actually recurse, just get queued up
        zza.track_transaction("#{base_zza_event}.backend.request.complete", tx_id, url)
        fetch_next
      end
    end
  end

  # called only once if client connection failed
  def client_connection_failed
    @http.on_error("Thin client failed")
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
          log_error "Lost client connection.  No more data will be fetched from back end."
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

  def more_work?
    @urls && @urls.length > 0
  end

  def begin_work
    @item_number = 1
    @total_number = @urls.length
    fetch_next
  end

  def clean_up
    @mgr.clean_up if @mgr
    @mgr = nil
    @http = nil
    super
  end
end
