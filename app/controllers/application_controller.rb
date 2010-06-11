# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :current_user?, :signed_in?
  filter_parameter_logging :password, :password_confirmation # Scrub sensitive parameters from log

  #protect_from_forgery # See ActionController::RequestForgeryProtection XSScripting protection

  layout :set_layout  # Sets the whole application layout

  private
    #
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

  
  private

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def current_user?(user)
      user == current_user
    end
  
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to root_path
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def signed_in?
       current_user
  end

  

    

end
