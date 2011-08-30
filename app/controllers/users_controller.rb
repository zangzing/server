class UsersController < ApplicationController
  ssl_required :join, :create, :edit_password, :update_password
  ssl_allowed :validate_email, :validate_username

  before_filter :require_user,    :only => [ :activate,:edit, :update]
  before_filter :require_admin,   :only => [ :activate]
  before_filter :correct_user,    :only => [:edit, :update]

  skip_before_filter :verify_authenticity_token, :only=>[:create]

  def join
    if params[:return_to]
        session[:return_to] = params[:return_to]
      end
    if ! current_user
      @new_user = User.new(:email => params[:email])
      @user_session = UserSession.new
      render :layout => false
    else
       redirect_back_or_default user_pretty_url(current_user)
    end
  end

  def create
    if current_user
        flash[:notice] = "You are currently logged in as #{current_user.username}. Please log out before creating a new account."
        session[:flash_dialog] = true
        redirect_to user_pretty_url(current_user)
        return
    end

    prevent_session_fixation

    @user_session = UserSession.new

    # RESERVED NAMES
    # check username if in magic format
    user_info = params[:user]
    checked_user_name = check_reserved_username(user_info)
    if checked_user_name.nil?
      @new_user = User.new()
      @new_user.set_single_error(:username, "You attempted to use a reserved user name without the proper key." )
      render :action => :join, :layout => false and return
    end

    # AUTOMATIC USERS
    #Check if user is an automatic user ( a contributor that has never logged in but has sent photos )
    @new_user = User.find_by_email( params[:user][:email])
    if @new_user && @new_user.automatic?
      # The user is an automatic user because she had contributed photos after being invited by email
      # she has now decided to join, remove automatic flag and reset password.
      @new_user.automatic = false
      @new_user.name      = params[:user][:name]
      @new_user.username  = params[:user][:username]
      @new_user.reset_password = true
      @new_user.password = params[:user][:password]
      @new_user.password_confirmation  = @new_user.password
    else
      @new_user = User.new(params[:user])
    end
    @new_user.reset_perishable_token
    @new_user.reset_single_access_token

    # SIGNUP CONTROL
    # new users are active by default
    if SystemSetting[:signup_control]
      @new_user.active = false
      @guest = Guest.find_by_email( params[:user][:email] )
      if @guest
        if SystemSetting[:always_allow_beta_listers] && @guest.beta_lister?
          @new_user.active = true #always allow when beta-lister is set and user is beta_lister
          SystemSetting[:new_users_allowed] -= 1 if SystemSetting[:new_users_allowed]
        else
          if SystemSetting[:new_users_allowed] > 0
            # user allotment available
            if @guest.share?
              if SystemSetting[:allow_sharers]
                @new_user.active= true
                SystemSetting[:new_users_allowed] -= 1
              end
            else
              @new_user.active= true
              SystemSetting[:new_users_allowed] -= 1
            end
          end
        end
      end
    end

    # CREATE USER
    if @new_user.active
      # Save active user,authlogic creates a session to log user in when we save
      if @new_user.save
        if @guest
          @guest.user_id = @new_user.id
          @guest.status = 'Active Account'
          @guest.save
        end
        flash[:success] = "Welcome to ZangZing!"
        @new_user.deliver_welcome!
        session[:show_welcome_dialog] = true unless( session[:return_to] )
        send_zza_event_from_client('user.join')
        redirect_back_or_default user_pretty_url( @new_user )
        return
      end
    else
      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      if @new_user.save_without_session_maintenance
        if @guest
          @guest.user_id = @new_user.id
          @guest.status = 'Inactive'
          @guest.save
        end
        send_zza_event_from_client('user.join')
        redirect_to inactive_url and return
      end
    end
    render :action=>:join,  :layout => false
  end

  def show
    @user = User.find(params[:id])
    redirect_to user_pretty_url(@user )
  end

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

  # mobile api
  def mobile_user_info
    begin
      user_id = params[:user_id]
      user = User.find(user_id)

      user_info = {
        :user_id                        => user_id,
        :username                       => user.username,
        :first_name                     => user.first_name,
        :last_name                      => user.last_name,
        :profile_url                    => user.profile_photo_url,
      }

      render :json => JSON.fast_generate(user_info)


    rescue Exception => ex
      render_json_error( ex ) and return
    end
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