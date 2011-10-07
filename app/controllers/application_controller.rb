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
    events = session[:send_zza_events_from_client] || []
    events << event
    session[:send_zza_events_from_client] = events
  end


  # change the session cookies, but keep
  # contents of the session hash
  def prevent_session_fixation
    old_session = session.clone
    reset_session

    old_session.keys.each do |key|
      session[key.to_sym] = old_session[key]
    end

  end


  # Authentication based on authlogic
  # returns false or the current user session
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  #
  # Authlogic
  # returns false or the current user
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  #
  # true if the given user is the current user
  def current_user?(user)
    user == current_user
  end

  #
  # Filter for methods that require a log in
  def require_user
    unless current_user
      if ZZ_API_VALID_VALUES.include?(request.headers[ZZ_API_HEADER])
        # this is the standard api error response format
        render_json_error(nil, "You must be logged in", 401)
      elsif request.xhr?
        flash.now[:error] = "You must be logged in to access this page"
        head :status => 401
      else
        flash[:error] = "You must be logged in to access this page"
        store_location
        redirect_to new_user_session_url
      end
    end
  end


  # This is the json version of require user. Saves the request referer instead of the
  # resquest fullpath so that the user returns to the page from where the xhr call originated
  # instead of then json-location. Instead of redirecting, it just returns 401 with an informative
  # json message that may or may not be used.
  def require_user_json
    unless current_user
      if ZZ_API_VALID_VALUES.include?(request.headers[ZZ_API_HEADER_RAILS])
        # this is the standard api error response format
        render_json_error(nil, "You must be logged in", 401)
      else
        session[:return_to] = request.referer
        render :json => "You must be logged in to call this url", :status => 401
      end
      return false
    end
    return true
  end

  # A variation of require_user_json that also requires the user_id param
  # to be the same user as current user or that the user is a support admin
  def require_same_user_json
    user_id = params[:user_id].to_i
    return false unless require_user_json
    # if we pass the first test, verify we are the user we want info on
    if current_user.id != user_id && current_user.support_hero? == false
      msg = "You do not have permissions to access this data, you can only access your own data"
      if ZZ_API_VALID_VALUES.include?(request.headers[ZZ_API_HEADER_RAILS])
        # this is the standard api error response format
        render_json_error(nil, msg, 401)
      else
        session[:return_to] = request.referer
        render :json => msg, :status => 401
      end
      return false
    end
    return true
  end


  # for act_as_authenticated compatibility with oauth plugin
  def login_required
    require_user
  end

  #
  # Filter for methods that require NO USER like sign in
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_path
      return false
    end
  end


  #
  #  Stores the intended destination of a rerquest to take the user there after log in
  def store_location

    # the dont_store_location param can be set by routes
    # that should not be stored for use after signin
    # see routes.rb for eaxmples
    if params[:dont_store_location] != true
      session[:return_to] = request.fullpath
    end
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
    session[:flash_dialog] = true
    redirect_to user_url(user_id), :status => 301
  end

  def user_not_found_redirect_to_homepage_or_potd
    flash[:notice] = "Sorry, we could not find the ZangZing user that you were looking for."
    session[:flash_dialog] = true
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
      response.headers['Content-Disposition'] =
          ( browser.chrome? ? "attachment; filename=#{opts[:filename]}" : "attachment; filename=\"#{opts[:filename]}\"" )
    else
      response.headers['Content-Disposition'] = "inline"
    end

    escaped_url = URI::escape(path.to_s)
    uri = URI.parse(escaped_url)
    response.headers['X-Accel-Redirect'] = "/nginx_redirect/#{uri.host}#{uri.path}"

    #response.headers["X-Accel-Redirect"] = path # nginx
    #response.headers['X-Sendfile'] = path # Apache and Lighttpd >= 1.5
    #response.headers['X-LIGHTTPD-send-file'] = path # Lighttpd 1.4

    Rails.logger.info "#{path} sent to client using X-Accel-Redirect"
    render :nothing => true
  end

  # standard json response form for async result polling
  def render_async_response_json(response_id)
    response_url = async_response_url(response_id)
    response.headers["x-poll-for-response"] = response_url
    render :json => {:message => "poll-for-response", :response_id => response_id, :response_url => response_url}
  end

  def associate_order
    return unless current_user and current_order
    current_order.associate_user!(current_user)
    session[:guest_token] = nil
  end

  # wraps a mobile api call and ensures that
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
  def mobile_api_core(skip_render, block)
    begin
      custom_err = MobileError.new
      result = block.call(custom_err)
      if skip_render == false
        if custom_err.err_set
          render_json_error(nil, custom_err.message, custom_err.code)
        elsif result.nil?
          head :status => 200
        else
          render :json => JSON.fast_generate(result)
        end
      end
    rescue Exception => ex
      render_json_error(ex)
    end
  end

  def mobile_api_self_render(&block)
    mobile_api_core(true, block)
  end

  def mobile_api(&block)
    mobile_api_core(false, block)
  end

end
