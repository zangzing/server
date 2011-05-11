class UserSessionsController < ApplicationController
  ssl_required :new, :create


  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  layout false


  def new
    if params[:return_to]
      session[:return_to] = params[:return_to]
      redirect_to signin_url
      return
    end


    if ! current_user
      @user_session = UserSession.new(:email=> params[:email])
    else
      redirect_to user_pretty_url(current_user)
    end
  end

  def create
    return_to = session[:return_to] #save the intended destination of the user if any
    reset_session # destroy the session to prevent Session Fixation Attack
    session[:return_to] = return_to  #restore the intended user destination
    @user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => true)
    if @user_session.save
      @user_session.user.reset_perishable_token! #reset the perishable token
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


  def inactive
  end

end
