class UserSessionsController < ApplicationController
  ssl_required :new, :create, :mobile_create
  skip_filter  :verify_authenticity_token, :only => [:mobile_create, :create]


  before_filter :only => [:new, :create]
#  before_filter :require_user, :only => :destroy

  layout false


  def new
     # URL Cleaning cycle
    if params[:return_to] || params[:email]
      session[:return_to] = params[:return_to] if params[:return_to]
      flash.keep
      if current_user
        redirect_back_or_default user_pretty_url(current_user) and return
      else
        session[:email] = params[:email] if params[:email]
        redirect_to signin_url and return
      end
    end

    if current_user
      redirect_to user_pretty_url(current_user) and return
    end

    if session[:email]
      @user_session = UserSession.new(:email=> session[:email] )
      session.delete(:email)
    else
      @user_session = UserSession.new
    end
  end

  def create
    prevent_session_fixation
    @user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => true)
    if @user_session.save
      @user_session.user.reset_perishable_token! #reset the perishable token
      redirect_back_or_default user_url( @user_session.record )
    else
      render :action => :new
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

  def mobile_create
    mobile_api do |custom_err|
      result = nil
      user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => false)
      if user_session.save
        result = {
            :user_credentials => user_session.record.persistence_token,
            :user_id =>  user_session.record.id,
            :username => user_session.record.username
        }
      else
        custom_err.set(user_session.errors.full_messages, 401)
      end
      result
    end
  end

  def mobile_destroy
    mobile_api do
      current_user_session.destroy if current_user
      nil
    end
  end


  def inactive
  end

end
