class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    reset_session #Prevent Session Fixation Attack
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      @user_session.user.reset_perishable_token! #reset the perishable token so it does not allow another login.
      redirect_back_or_default user_url( @user_session.record )
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default root_url
  end

end
