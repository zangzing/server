require 'eventmachine/lib/event_machine_rpc'

#
#  ApplicationController
#
#  2010 Copyright  ZangZing LLC
#
#  Base class for all controllers
#  Filters added to this controller apply to all controllers in the application.
#  Public Methods added will be available for all controllers.
#  helper_method methods will also be available in all views

class ApplicationController < ActionController::Base
  JSON_MEDIA_TYPE = 'application/json'.freeze


  include ZZSslRequirement
  include ZZ::Auth
  include ZZ::ZZAController
  include PrettyUrlHelper
  include ResponseActionsHelper
  include BuyHelper
  include Spree::CurrentOrder

  helper :all # include all helpers, all the time

  helper_method :user_pretty_url, :album_pretty_url, :photo_pretty_url,
                :back_to_home_page_url, :back_to_home_page_caption, :current_order

  before_filter :check_referrer_and_reset_last_home_page

  after_filter :flash_to_headers

  layout  proc{ |c| c.request.xhr? ? false : 'main' }

  # If its an AJAX request, move the flashes to a custom header for JS handling on the client
  # removes the flash from the session because it was a json cal so we do not want it there
  # it is called after
  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Flash'] = flash.to_json if flash.length > 0
    # must pass status code as a string or you will kill rack since
    # it is expecting a string
    response.headers['X-Status'] = response.status.to_s
  end

  def errors_to_headers( record )
    #return unless request.xhr?
    response.headers['X-RecordType'] = record.class.name
    response.headers['X-Errors'] = record.errors.full_messages.to_json
  end



  def send_zza_event_from_client (event)
    add_javascript_action('send_zza_event_from_client', {:event => event})
  end

  #
  #  these helpers and filters are used to manage the 'all albums' back button
  def store_last_home_page(user_id)
    session[:last_home_page] = user_id
  end

  def last_home_page
    session[:last_home_page]
  end

  def check_referrer_and_reset_last_home_page
    unless request.referer.include? "http://#{request.host_with_port}"
      session[:last_home_page] = nil
    end
  end


  def back_to_home_page_url(album)
    user_id = last_home_page
    if user_id
      return user_pretty_url User.find(user_id)
    else
      return user_pretty_url album.user
    end
  end

  def back_to_home_page_caption(album)
    user_id = last_home_page
    if current_user && user_id == current_user.id
      return "My Albums"
    elsif user_id
      return User.find(user_id).posessive_short_name + " Albums"
    else
      return album.user.posessive_short_name + " Albums"
    end
  end

  def set_show_comments_cookie
    cookies[:hide_comments] = {:value => 'false', :path => '/'}
  end



  def album_not_found_redirect_to_owners_homepage(user_id)
    flash[:notice] = "Sorry, we could not find the album that you were looking for."
    add_javascript_action( 'show_message_dialog',  {:message => flash[:notice]})
    redirect_to user_url(user_id), :status => 301
  end

  def user_not_found_redirect_to_homepage_or_potd
    flash[:notice] = "Sorry, we could not find the ZangZing user that you were looking for."
    add_javascript_action( 'show_message_dialog',  {:message => flash[:notice]})
    if current_user
      redirect_to user_url(current_user)
    else
      redirect_to potd_path, :status => 301
    end
  end

  def x_accel_redirect(path, opts ={})
    if opts[:type]
      response.headers['Content-Type'] = opts[:type]
    else
      response.headers['Content-Type'] = "application/octet-stream"
    end
    # Set a binary Content-Transfer-Encoding, or ActionController::AbstractResponse#assign_default_content_type_and_charset!
    # will set a charset to the Content-Type header.
    response.headers['Content-Transfer-Encoding'] = 'binary' unless response.headers['Content-Type'].match(/text\/.*/)
    response.headers['Content-Disposition'] = "attachment;"
    if opts[:filename]
      response.headers['Content-Disposition'] = "attachment; filename=\"#{opts[:filename]}\""
    else
      response.headers['Content-Disposition'] = "inline"
    end

    escaped_url = URI::escape(path.to_s)
    uri = URI.parse(escaped_url)
    query = uri.query.blank? ? '' : "?#{uri.query}"
    response.headers['X-Accel-Redirect'] = "/nginx_redirect/#{uri.host}#{uri.path}#{query}"

    #response.headers["X-Accel-Redirect"] = path # nginx
    #response.headers['X-Sendfile'] = path # Apache and Lighttpd >= 1.5
    #response.headers['X-LIGHTTPD-send-file'] = path # Lighttpd 1.4

    Rails.logger.info "#{path} sent to client using X-Accel-Redirect"
    render :nothing => true
  end

  # return with preparation for a album zip
  def nginx_zip_mod(filename, contents)
    filename = ZZUtils.build_safe_filename(filename, 'zip')
    # Set a binary Content-Transfer-Encoding, or ActionController::AbstractResponse#assign_default_content_type_and_charset!
    # will set a charset to the Content-Type header.
    response.headers['Content-Transfer-Encoding'] = 'binary'
    response.headers['Content-Disposition'] =
        ( browser.chrome? ? "attachment; filename=#{filename}" : "attachment; filename=\"#{filename}\"" )
    response.headers['X-Archive-Files'] = 'zip'
    Rails.logger.info "Sending zipped album #{filename} to client"
    render :content_type => "application/octet-stream", :text => contents
  end

  # prepare event machine async proxy call
  # if missing will add on the user context to the hash passed in
  # pass in the command, we will prepend the proper eventmachine proxy
  # address and append the json data file location
  # so if you pass in a command of zip_download it will be converted to
  # /proxy_eventmachine/zip_download?json_path=/data/tmp/json_ipc/62845.1323732431.61478.6057566634.json
  # DO NOT add / to either end of the command
  #
  def prepare_proxy_eventmachine(command, data)
    context = data[:user_context]
    if context.nil?
      # add in user context
      user_id, user_type, ip = zza_user_context
      context = {
          :user_id => user_id,
          :user_type => user_type,
          :user_ip => ip
      }
      data[:user_context] = context
    end
    data[:parse_test_flag] = 'valid'
    rpc_path = EventMachineRPC.generate_json_file(data)

    # now verify that json parses
    # looks like a GC related bug in the json generator was fixed in JSON 1.6.1 or later
    # so probably don't need this sanity check anymore
    begin
      json_str = File.read(rpc_path)
      Rails.logger.info "EventMachineRPC: crc32: #{Zlib.crc32(json_str, 0)}, path: #{rpc_path}"
      parsed = JSON.parse(json_str)
      raise "Parsed data is invalid" if parsed['parse_test_flag'] != 'valid'
    rescue Exception => ex
      Rails.logger.error "In prepare_proxy_eventmachine, the json file was corrupt: #{ex.message}"
      raise ex
    end

    response.headers['X-Accel-Redirect'] = "/proxy_eventmachine/#{command}?json_path=#{rpc_path}"
    rpc_path
  end

  # standard json response form for async result polling
  def render_async_response_json(response_id)
    response_url = async_response_url(response_id)
    response.headers["x-poll-for-response"] = response_url
    render :json => {:message => "poll-for-response", :response_id => response_id, :response_url => response_url}
  end

  # determine if we can return pre zipped data based on the
  # the client accept encodings
  def client_accepts_gzip?
    # now see if they accept gzip
    return false if request.accept_encoding.nil?
    encoding_types = request.accept_encoding.split(',')
    encoding_types.each do |type|
      return true if type.strip == 'gzip'
    end
    return false
  end


  # a helper to handle json return to client
  # if the data is compressed we determine if
  # the client can handle it, if so it is passed
  # on, otherwise we must decompress and then hand
  # it back
  def render_cached_json(json, public, compressed)
    ver = params[:ver]
    if ver.nil? || ver == '0'
      # no cache
      expires_now
    else
      expires_in 1.year, :public => public
    end
    if compressed
      # data is currently compressed see if client can handle it
      if client_accepts_gzip?
        # ok, client can take it as is
        response.headers['Content-Encoding'] = 'gzip'
      else
        # must deflate it and send plain
        Rails.logger.warn("render_cached_json had to convert compressed json to decompressed json since browser does not accept gzip encoding - user agent: #{request.user_agent} - accept_enconding: #{request.accept_encoding}")
        json = ActiveSupport::Gzip.decompress(json)
      end
    end
    render :json => json
  end

  def associate_order
    return unless current_user and current_order
    current_order.associate_user!(current_user)
    session[:guest_token] = nil
  end

  # takes the params passed and applies the valid_params array
  # as a filter of which ones we accept and then produces
  # a new hash with the filtered params
  def filter_params(params, valid_keys)
    filtered = {}
    valid_keys.each do |key|
      filtered[key] = params[key] if params.has_key?(key)
    end
    filtered
  end

  # wraps an active model error with a ZZAPIError
  # by extracting the full error text array
  def active_model_error(err)
    return ZZAPIError
  end
  # wraps a zz api call and ensures that
  # we handle exceptions cleanly and put into proper
  # format - does the render so expects the block
  # to return a hash that represents the result
  #
  # we pass custom_err to the block which allows the
  # block to set specific error messages and code
  # if this is not set and no exception is thrown
  # we assume success and will create a json string
  # of the result hash.  If the hash is nil we assume
  # no response is wanted and return only head
  #
  # Keep in mind that because we call a block, that
  # block must not use return at the top level since
  # return in a block exits out to our caller without
  # coming back to us first
  def zz_api_core(filter, skip_render, block)
    return unless require_zz_api # anything using these api wrappers enforces require_zz_api
    begin
      result = block.call
      if skip_render == false
        if result.nil?
          head :status => 200
        else
          render :json => JSON.fast_generate(result)
        end
      end
    rescue Exception => ex
      ex = filter.custom_error(ex) if filter
      if ex.is_a?(ZZAPIError)
        # a custom error which can have a string, hash, or array
        render_json_error(ex, ex.result, ex.code)
      else
        render_json_error(ex)
      end
    end
  end

  def zz_api_self_render(filter = nil, &block)
    zz_api_core(filter, true, block)
  end

  def zz_api(filter = nil, &block)
    zz_api_core(filter, false, block)
  end

end
