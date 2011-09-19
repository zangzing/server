class UserSessionsController < ApplicationController

  ssl_required :new, :create, :mobile_create
  skip_filter  :verify_authenticity_token, :only => [:mobile_create, :create]


  after_filter :associate_order, :only => [:create]

  layout false


  def new
    if params[:return_to]
      session[:return_to] = params[:return_to]
      flash.keep
      redirect_to signin_url
      return
    end


    if ! current_user
      @user_session = UserSession.new(:email=> params[:email])
    else
       redirect_back_or_default user_pretty_url(current_user)
    end
  end

  def create
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
