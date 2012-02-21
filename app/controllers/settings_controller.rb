class SettingsController < ApplicationController
  ssl_required :join, :create, :edit_password, :update_password
  ssl_allowed :validate_email, :validate_username

  before_filter :require_user,    :only => [ :activate,:edit, :update]
  before_filter :require_admin,   :only => [ :activate]
  before_filter :correct_user,    :only => [:edit, :update]

  skip_before_filter :verify_authenticity_token, :only=>[:create]



  def edit
    @user = current_user
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your Password Has Been Changed."
      redirect_to user_pretty_url(@user)
    else
      render :action => :edit_password
    end
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your Profile Has Been Updated."
      redirect_to user_path(@user)
    else
#      flash[:error] = @user.errors
      render :action => :edit
    end
  end

  def validate_email
    if params[:user] && params[:user][:email]
      @user = User.find_by_email(params[:user][:email])
      if @user == current_user #if the email returns the current user this means its a profile edit
        @user = nil
      end
      if @user && @user.automatic?
        render :json => true and return  #The user is an automatic user so the email is still technically available.
      end
      render :json => !@user and return
    end
    render :json => true #Invalid call return not valid
  end

  def validate_username
    if params[:user] && params[:user][:username]
      if ReservedUserNames.is_reserved? params[:user][:username]
        render :json => false and return
      elsif
        @user = User.find_by_username(params[:user][:username])
        if @user == current_user #if the username returns the current user this means its a profile edit
          @user = nil
        end
        if @user && @user.automatic?
          render :json => true and return  #The user is an automatic user so the username is still technically available.
        end
        render :json => !@user and return
      end

    end
    render :json => true #Invalid call return not valid
  end


  private
  def admin_user
    redirect_to( root_path ) unless current_user.admin?
  end

  def correct_user
    if params[:id]
      @user = User.find(params[:id])
    elsif params[:username]
      @user = User.find_by_username(params[:username])
    end

    redirect_to( root_path ) unless current_user?(@user)
  end

  # see if this is a reserved username and if proper key has been passed
  # updates the user_info with the outcome, nil for bad, updated name otherwise
  def check_reserved_username user_info
    user_name = user_info[:username]
    checked_user_name = ReservedUserNames.verify_unlock_name(user_name)

    # if we get a nil checked_user_name it is because the name was reserved
    # and the unlock code was wrong.  We will pass the nil on to force an
    # error.
    user_info[:username] = checked_user_name

    return checked_user_name
  end



end