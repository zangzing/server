class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :edit, :update, :destroy]
  before_filter :admin_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]


  def new
      @title = "Sign up"
      @user = User.new
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

      @user = User.new(params[:user])
      @user.reset_perishable_token
  	  @user.reset_single_access_token


      # USER ACTIVATION DISABLED Do Not Erase        
      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      #if @user.save_without_session_maintenance
      #   @user.deliver_activation_instructions!
      #   flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      #   redirect_to root_url
         
      if @user.save
            flash[:success] = "Welcome to ZangZing!"
            @user.deliver_welcome!
            redirect_back_or_default @user
      else
        check_for_name_error(checked_user_name, @user)
        render :action => :new
      end
  end
  
  def show
      @user = User.find(params[:id]) 
      redirect_to  user_albums_path(@user )
  end
  
  def edit 
    @user = @current_user    
    render :layout => false
  end

  def account
    @user = @current_user
    render :layout => false
  end

  def notifications
    @user = @current_user
    render :layout => false
  end
  
  def update
    @user = current_user
    # check username if in magic format
    user_info = params[:user]
    new_user_name = user_info[:username]
    if new_user_name != @user.username
      checked_user_name = check_reserved_username(user_info)
    end
    if @user.update_attributes(user_info)
      flash[:notice] = "Your Profile Has Been Updated."
      respond_to do |format|
          format.html  { redirect_to @user   }
          format.json { render :json => "", :status => 200 and return }
       end
    else
      check_for_name_error(checked_user_name, @user)
      respond_to do |format|
          format.html  { render :action => :edit   }
          format.json  { errors_to_headers( @user )
                         render :json => "", :status => 400 and return}
       end
    end
  end
  
#  def index
#    @title = "All users"
#    @users = User.paginate(:page =>params[:page])
#  end
  
  def destroy
    user = User.find(params[:id])
    if user == current_user && user.admin? then
      flash[:notice] ="Unable to self destroy. Ask other admin to do it"
    else
      user.destroy
      flash[:success] ="User Deleted"
    end
    redirect_to users_path
  end

  def validate_email
    if params[:user] && params[:user][:email]
      @user = User.find_by_email(params[:user][:email])
      if @user == current_user #if the email returns the current user this means its a profile edit
        @user = nil
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