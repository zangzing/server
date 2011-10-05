#
#  2010 Copyright  ZangZing LLC
#
#  This auth/auth module is included in application controller and spree base controller
#  it is the centralized location for all auth/auth controller functions
#

module ZZ
  module Auth
    extend ActiveSupport::Concern

     ZZ_API_HEADER = 'X-ZangZing-API'.freeze
     ZZ_API_HEADER_RAILS = 'HTTP_X_ZANGZING_API'.freeze
     ZZ_API_VALID_VALUES = ['mobile'].freeze


    included do
      protect_from_forgery # See ActionController::RequestForgeryProtection XSScripting protection

      helper_method :current_user_session, :current_user, :current_user?,:signed_in?

      # this basic filter uses a hardcoded username/password - we must turn off the
      # AuthLogic  support with allow_http_basic_auth false on the UserSession since
      # it can't seem to cope with a seperate scheme in rails 3
      before_filter :protect_with_http_auth
    end

    #No class methods to add so no module ClassMethods

    module InstanceMethods
      # change the session cookies, but keep
      # contents of the session hash
      def prevent_session_fixation
        old_session = session.clone
        reset_session
        old_session.keys.each do |key|
          session[key.to_sym] = old_session[key]
        end
      end



      # Authlogic
      # returns false or the current user session
      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      # Authlogic
      # returns false or the current user
      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end

      # True if a user is signed in. Left in place for backwards compatibility
      # better to use if current_user ......
      alias_method :signed_in?, :current_user
      alias_method :logged_in?, :current_user

      # true if the given user is the current user
      def current_user?(user)
        user == current_user
      end

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

      # standard json response error
      def render_json_error(ex, message = nil, code = nil)
        error_json = AsyncResponse.build_error_json(ex, message, code)
        render :status => 509, :json => error_json
      end

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


      # for act_as_authenticated compatibility with oauth plugin
      alias_method :login_required, :require_user

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

      # Filter for methods that require NO USER like sign in
      def require_no_user
        if current_user
          store_location
          flash[:notice] = "You must be logged out to access this page"
          redirect_back_or_default root_path
        end
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
        # see if we have http_auth turned on
        return unless ZangZingConfig.config[:requires_http_auth]

        allowed = {
            :actions => ['photos#agent_index',
                         'photos#agent_create',
                         'photos#upload_fast',
                         'photos#simple_upload_fast',
                         'oauth#access_token',
                         'oauth#request_token',
                         'oauth#agentauthorize',
                         'oauth#test_request',
                         'oauth#test_session',
                         'connector/local_contacts#import',
                         'sendgrid#import_fast',
                         'sendgrid#events',
                         'sendgrid#un_subscribe',
                         'pages#health_check',
                         'agents#check',
                         'agents#info',
                         'agents#index',
                         'admin/guests#create',

                         #let facebook crawlers in
                         'photos#index',
                         'albums#index'
            ]

        }
        unless allowed[:actions].include?("#{params[:controller]}##{params[:action]}")
          authenticate_or_request_with_http_basic('ZangZing Photos') do |username, password|
            username == Server::Application.config.http_auth_credentials[:login] && password == Server::Application.config.http_auth_credentials[:password]
          end
        end
      end

      #
      # To be run as a before_filter

      # Assumes @album is the album in question and current_user is the user we are evaluating
      def require_album_admin_role
        unless  @album.admin?( current_user.id ) || current_user.support_hero?
          flash.now[:error] = "Only Album admins can perform this operation"
          response.headers['X-Errors'] = flash[:error]
          if request.xhr?
            head :status => 401
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
            if request.xhr?
              flash.now[:notice] = "You have asked to see a password protected album. Please login so we know who you are."
              head :status => 401 and return
            else
              flash[:notice] = "You have asked to see a password protected album. Please login so we know who you are."
              store_location
              redirect_to new_user_session_url and return
            end
          end
          unless @album.viewer?( current_user.id ) || current_user.moderator?
            if request.xhr?
              flash[:notice] = "You have asked to see a password protected album. You do not have enough privileges to see it"
              head :status => 401
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
        unless  @album.contributor?( current_user.id ) || current_user.support_hero? || @album.everyone_can_contribute?
          flash.now[:error] = "Only Contributors admins can perform this operation"
          render_401
        end
      end

      # To be run as a before_filter
      # Will render a 401 page if the currently logged in user is not an admin
      def require_admin
        unless current_user.admin?
          flash.now[:error] = "Administrator privileges required for this operation"
          render_401
        end
      end

    end #Instance Methods


    def render_404(exception = nil)
      respond_to do |type|
        type.html { render :status => :not_found, :file    => "#{Rails.root}/public/404.html", :layout => nil}
        type.all  { render :status => :not_found, :nothing => true }
      end
    end

    def render_401(exception = nil)
      respond_to do |type|
        type.html { render :status => :unauthorized, :file    => "#{Rails.root}/public/401.html", :layout => nil}
        type.all  { render :status => :unauthorized, :nothing => true }
      end
    end

  end
end