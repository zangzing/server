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
  include SslRequirement
  include ZZ::Auth
  include ZZ::ZZAController
  include PrettyUrlHelper

  helper :all # include all helpers, all the time

  helper_method :user_pretty_url, :album_pretty_url, :photo_pretty_url,
                :back_to_home_page_url, :back_to_home_page_caption

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
    flash.discard  # don't want the flash to appear when you reload page 
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

  #def x_accel_pdf(path, filename)
  #  x_accel_redirect(path, :type => "application/pdf",
  #                         :filename => filename)
  #end

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

  # standard json response error
  def render_json_error(ex)
    error_json = AsyncResponse.build_error_json(ex)
    render :status => 509, :json => error_json
  end

end
