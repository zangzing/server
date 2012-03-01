class UserSessionsController < ApplicationController

  ssl_required :new, :create
  skip_filter  :verify_authenticity_token, :only => [:create]


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
    if any_current_user
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

  # NOTE, the zz_api login and logout methods are in the users_controller since
  # we also support create there as well and it makes sense to unify them
  # in one place.

  def inactive
  end

end
