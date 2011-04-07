class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    if ! current_user
      @user_session = UserSession.new
    else
      redirect_to user_pretty_url(current_user)
    end
  end

  def join
    if ! current_user
      @user_session = UserSession.new
    else
      redirect_to user_pretty_url(current_user)
    end
  end

  def create
    return_to = session[:return_to] #save the intended destination of the user if any
    reset_session # destroy the session to prevent Session Fixation Attack
    session[:return_to] = return_to  #restore the intended user destination
    @user_session = UserSession.new(:email => params[:user_session][:email], :password => params[:user_session][:password], :remember_me => true)
    if @user_session.save
      @user_session.user.reset_perishable_token! #reset the perishable token so it does not allow another login.

      redirect_back_or_default user_url( @user_session.record )
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
#    flash.now[:notice] = "Logout successful!"
    redirect_back_or_default root_url
  end
end
