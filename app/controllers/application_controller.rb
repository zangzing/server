#
#  ApplicationController
#
#  2010 Copyright  ZangZing LLC
#
#  Base class for all controllers



class ApplicationController < ActionController::Base

  # Filters added to this controller apply to all controllers in the application.
  # Public Methods added will be available for all controllers.
  # helper_method methods will also be available in all views
                                                               

  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :current_user?, :signed_in?
  filter_parameter_logging :password, :password_confirmation # Scrub sensitive parameters from log

  #protect_from_forgery # See ActionController::RequestForgeryProtection XSScripting protection

  layout :set_layout  # Sets the whole application layout

  private

    # If there is a user logged in then set the layout to match user preferences
    # otherwise set it to the default which is white.
    #
    def set_layout
      if current_user_session
       current_user.style
      else
        "white"
      end
    end

    #
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
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
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
      session[:return_to] = request.request_uri
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
end
