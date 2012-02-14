class UserSessionsController < ApplicationController

  ssl_required :new, :create, :zz_api_create
  skip_filter  :verify_authenticity_token, :only => [:zz_api_create, :create]


  after_filter :associate_order, :only => [:create]

  layout false


  def new
     # URL Cleaning cycle
    if params[:return_to] || params[:email]
      session[:return_to] = params[:return_to] if params[:return_to]
      flash.keep
      unless current_user
        session[:email] = params[:email] if params[:email]
        redirect_to signin_url and return
      end
    end

    if current_user
      redirect_back_or_default user_pretty_url(current_user)
      return
    end

    if session[:email]
      @user_session = UserSession.new(:email=> session[:email] )
      session.delete(:email)
    else
      @user_session = UserSession.new
    end
  end

  def create
    clear_buy_mode_cookie
    @user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => true)
    if @user_session.save
      prevent_session_fixation
      @user_session.user.reset_perishable_token! #reset the perishable token
      redirect_back_or_default user_url( @user_session.record )
    else
      if params[:store_signin]
        flash[:error] = "Invalid user/password combination"
        redirect_to params[:store_signin]
      else
        render :action => :new
      end
    end
  end

  def destroy
    if current_user
      if  session[:impersonation_mode] == true
        redirect_to admin_unimpersonate_url
      else
        current_user_session.destroy
        reset_session
        redirect_back_or_default root_url
      end
    else
        redirect_to root_url
    end
  end

  # Logs a user in.
  #
  # After login, the user credentials will be returned as well as the
  # system rights for that user.
  #
  # This is called as (POST):
  #
  # /zz_api/login
  #
  #
  # Input:
  # {
  #   :email => the username or email to log in with,
  #   :password => the password,
  # }
  #
  #
  # Returns:
  # the credentials and user rights
  #
  # {
  #   :user_id => id of this user,
  #   :user_credentials => a string representing the user credentials, to use, set
  #       the user_credentials cookie to this value
  #   :username => the username for this user,
  #   :server => the host you are connected to
  #   :role => the system rights for this user, can be one of
  #     the :available_roles such as:
  #     Admin,Hero,SuperModerator,Moderator,User
  #     The roles are shown from most access to least
  #     So, for example, if you need Moderator rights and you are an Admin
  #     you will be granted access.  On the other hand, if
  #     you are a User you will not be granted access.
  #   :available_roles => Ordered from most access to least lets you determine
  #     the available roles and their order
  # }
  #
  def zz_api_create
    zz_api do
      user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => false)
      if user_session.save
        acl = SystemRightsACL.singleton
        role = acl.get_user_role(current_user.id)
        if role.nil?
          role = SystemRightsACL::USER_ROLE
          acl.add_user(current_user, role)
        end
        result = {
            :user_credentials => current_user.persistence_token,
            :user_id =>  current_user.id,
            :username => current_user.username,
            :server => Server::Application.config.application_host,
            :role => role.name,
            :available_roles => SystemRightsACL.role_names
        }
      else
        raise ZZAPIError.new(user_session.errors.full_messages, 401)
      end
      result
    end
  end

  def zz_api_destroy
    zz_api do
      current_user_session.destroy if current_user
      nil
    end
  end


  def inactive
  end

end
