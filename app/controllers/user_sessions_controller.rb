class UserSessionsController < ApplicationController

  ssl_required :new, :create, :mobile_create
  skip_filter  :verify_authenticity_token, :only => [:mobile_create, :create]


  before_filter :only => [:new, :create]
#  before_filter :require_user, :only => :destroy

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
       redirect_back_or_default user_pretty_url(current_user)
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
      @user_session = UserSession.new(:email => params[:email], :password => params[:password], :remember_me => false)
      if @user_session.save
        render :json => { :user_credentials => @user_session.record.single_access_token,
                          :user_id =>  @user_session.record.id,
                          :username => @user_session.record.username 
        }
      else
        errors_to_headers( @user_session )
        head :status => 401
       end
  end

  def mobile_destroy
      if current_user
          current_user_session.destroy
      end
      head :status => 200
  end
  
end
