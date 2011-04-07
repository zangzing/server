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

  helper_method :current_user_session, :current_user, :current_user?, :signed_in?,
      :user_pretty_url, :album_pretty_url, :photo_pretty_url, :back_to_home_page_url

  # this basic filter uses a hardcoded username/password - we must turn off the
  # AuthLogic  support with allow_http_basic_auth false on the UserSession since
  # it can't seem to cope with a seperate scheme in rails 3
  before_filter :protect_with_http_auth
  before_filter :check_referrer_and_reset_last_home_page

  after_filter :flash_to_headers

  protect_from_forgery # See ActionController::RequestForgeryProtection XSScripting protection

  layout  proc{ |c| c.request.xhr? ? false : 'main' }

  private

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
        flash[:error] = "You must be logged in to access this page"
        if request.xhr?
          render :nothing => true, :status => 401
        else
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
        :actions => ['photos#agent_index',
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

  #
  # To be run as a before_filter
  # Assumes @album is the album in question and current_user is the user we are evaluating
  def require_album_admin_role
    unless  @album.admin?( current_user.id ) || current_user.support_hero?
      flash[:error] = "Only Album admins can perform this operation"
      response.headers['X-Errors'] = flash[:error]
      if request.xhr?
        render :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end
  end

  #
  # To be run as a before_filter
  # Assumes @album is the album in question and current_user is the user we are evaluating
  # User has viewer role if ( Album private and logged in and has viewer role ) OR
  # ( Album not private )
  def require_album_viewer_role
    if @album.private?
      unless current_user
        flash[:notice] = "You have asked to see a password protected album. Please login so we know who you are."
        if request.xhr?
          render :status => 401
        else
          store_location
          redirect_to new_user_session_url and return
        end
      end
      unless @album.viewer?( current_user.id ) || current_user.moderator?
        if request.xhr?
          flash[:notice] = "You have asked to see a password protected album. You do not have enough privileges to see it"
          render :status => 401
        else
          session[:client_dialog] = album_pwd_dialog_url( @album )
          redirect_to user_url( @album.user ) and return
        end
      end
    end
  end


  #
  # To be run as a before_filter
  # Assumes @album is the album in question and current_user is the user we are evaluating
  def require_album_contributor_role
    unless  @album.contributor?( current_user.id ) || current_user.support_hero?
      flash[:error] = "Only Contributors admins can perform this operation"
      response.headers['X-Error'] = flash[:error]
      if request.xhr?
        render :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end
  end

  def self.album_pretty_path (username, friendly_id)
    return "/#{username}/#{friendly_id}"
  end


  def album_pretty_url (album, friendly_id = nil)
    friendly_id = friendly_id.nil? ? album.friendly_id : friendly_id
    return "http://#{request.host_with_port}#{ApplicationController.album_pretty_path(album.user.username, friendly_id)}"
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
