#
#  ApplicationController
#
#  2010 Copyright  ZangZing LLC
#
#  Base class for all controllers

class ApplicationController < ActionController::Base

  # give the zza worker a chance to restart if we are running
  # as a forked process because it will have been killed in that
  # case.  Later when we move to Amazon we can control the Unicorn
  # config file directly and do it only once from within there
  ZZ::ZZA.after_fork_check

  # Filters added to this controller apply to all controllers in the application.
  # Public Methods added will be available for all controllers.
  # helper_method methods will also be available in all views


  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :current_user?, :signed_in?
  # this basic filter uses a hardcoded username/password - we must turn off the
  # AuthLogic  support with allow_http_basic_auth false on the UserSession since
  # it can't seem to cope with a seperate scheme in rails 3
  before_filter :protect_with_http_auth

  after_filter :flash_to_headers

  protect_from_forgery # See ActionController::RequestForgeryProtection XSScripting protection

  layout  proc{ |c| c.request.xhr? ? false : 'main' }

  private

  # If its an AJAX request, move the flashes to a custom header for JS handling on the client
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
        store_location unless request.xhr?
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end


    # This is the json version of require user. Saves the request referer instead of the
    # resquest fullpath so that the user returns to the page from where the xhr call originated
    # instead of then json-location. Instead of redirecting, it just returns 401 with an informative
    # json message that may or may not be used.
    def require_user_json
      unless current_user
        session[:return_to] = request.referer
        render :json => "You must be logged in to call this url", :status => 401
        return false
      end
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
      session[:return_to] = request.fullpath
    end

    #
    # Redirects the user to the desired location after log in. If no stored location then to the default location
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    #
    # True if a user is signed in. Left in place for backwards compatibility
    # better to use if current_user ......
    def signed_in?
       current_user
    end

    #
    # An additional way to control access to certain actions like the ones that are only available to the owner
    # TODO: Implement this if needed.
    # Do not remove it its for act_as_Authenticated compatibility
    #
    def authorized?
      true
    end

    def protect_with_http_auth
      allowed = {
        :actions => ['photos#index',
                     'photos#agentindex',
                     'photos#agent_create',
                     'photos#upload_fast',
                     'oauth#access_token',
                     'oauth#request_token',
                     'oauth#agentauthorize',
                     'oauth#test_request',
                     'oauth#test_session',
                     'connector/local_contacts#import',
                     'sendgrid#import_fast',
                     'pages#health_check',
                     'agents#check',
                     'agents#info',
                     'agents#index']
      
      }

      unless request.remote_ip.starts_with?('69.63.180') || request.remote_ip.starts_with?('66.220.149') #allow facebook crawler
        unless allowed[:actions].include?("#{params[:controller]}##{params[:action]}")
          authenticate_or_request_with_http_basic('ZangZing Photos') do |username, password|
            username == Server::Application.config.http_auth_credentials[:login] && password == Server::Application.config.http_auth_credentials[:password]
          end
        end
      end
    end


  #todo: move these to helper?
  def album_pretty_url (album)
    return "http://#{request.host_with_port}/#{album.user.username}/#{album.friendly_id}/photos"
  end

  def photo_pretty_url(photo)
    return "http://#{request.host_with_port}/#{photo.album.user.username}/#{photo.album.friendly_id}/photos/#!#{photo.id}"
  end

  def photo_url(photo)
     return album_photos(photo.album) + "/#!{photo.id}"
  end

  def user_pretty_url(user)
    return "http://#{request.host_with_port}/#{user.username}"
  end

end
