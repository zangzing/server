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
      redirect_back_or_default root_url
    elsif @user_session.attempted_record &&
        !@user_session.invalid_password? &&
        !@user_session.attempted_record.active?
         @user_session.errors.add( :base, '<a href="'+
                        resend_activation_path(:username => @user_session.attempted_record.username)+
                       '">Resend activation email</a>');
      render :action => :new
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
