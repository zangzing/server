class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :edit, :update, :destroy]
  before_filter :admin_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]


  def new
      @title = "Sign up"
      @new_user = User.new
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

  # check the name are add an error if nil
  def check_for_name_error(checked_user_name, user)
    if checked_user_name.nil?
      # A reserved name that didn't have the right key
      msg = "You attempted to use a reserved user name without the proper key."
      user.set_single_error(:username, msg)
    end
  end

  def create
      # check username if in magic format
      user_info = params[:user]
      checked_user_name = check_reserved_username(user_info)

      @new_user = User.find_by_email( params[:user][:email])
      if @new_user && @new_user.automatic?
        @new_user.automatic = false
        @new_user.name      = params[:user][:name]
        @new_user.username  = params[:user][:username]
        @new_user.password  = params[:user][:password]
      else
        @new_user = User.new(params[:user])
      end
      @new_user.reset_perishable_token
  	  @new_user.reset_single_access_token


      # USER ACTIVATION DISABLED Do Not Erase        
      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      #if @new_user.save_without_session_maintenance
      #   @new_user.deliver_activation_instructions!
      #   flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      #   redirect_to root_url
         
      if @new_user.save
            flash[:success] = "Welcome to ZangZing!"
            @new_user.deliver_welcome!
            UserSession.create(@new_user, true)

            session[:show_welcome_dialog] = true
            
            redirect_back_or_default @new_user
      else
        check_for_name_error(checked_user_name, @new_user)
        render :action => :new
      end
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


  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your Profile Has Been Updated."
      redirect_to user_albums_path(@user)
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

      @user = User.find_by_username(params[:user][:username])
      if @user == current_user #if the username returns the current user this means its a profile edit
        @user = nil
      end
      render :json => !@user and return

    end
    render :json => true #Invalid call return not valid
  end
  

  private
    def admin_user
          redirect_to( root_path ) unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to( root_path ) unless current_user?(@user)
    end

    
end