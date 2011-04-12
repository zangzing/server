class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user,    :only => [:index, :activate,:edit, :update]
  before_filter :require_admin,   :only => [:index,:activate]
  before_filter :correct_user,    :only => [:edit, :update]

  def new
      @title = "Sign up"
      @new_user = User.new
  end

  def create
      # check username if in magic format
      user_info = params[:user]
      checked_user_name = check_reserved_username(user_info)
      if checked_user_name.nil?
        @new_user = User.new()
        @new_user.set_single_error(:username, "You attempted to use a reserved user name without the proper key." )
        render :action => :new and return
      end

      #Check if user is an automatic user ( a contributor that has never logged in but has sent photos )
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

      # new users are active by default
      if SystemSetting[:signup_control]
        @new_user.active = false
        @guest = Guest.find_by_email( params[:user][:email] )
        if @guest
           if SystemSetting[:always_allow_beta_listers] && @guest.beta_lister?
              @new_user.active = true #always allow when beta-lister is set and user is beta_lister
           else
              if SystemSetting[:new_users_allowed] > 0
                # user allotment available
                if @guest.share?
                  if SystemSetting[:allow_sharers]
                    @new_user.active= true
                    SystemSetting[:new_users_allowed] -= 1;
                  end
                else
                  @new_user.active= true
                  SystemSetting[:new_users_allowed] -= 1;
                end
              end
           end
        end
      end

      if @new_user.active
        #Save active user
        if @new_user.save
            if @guest
               @guest.user_id = @new_user.id
               @guest.status = 'Active Account'
               @guest.save
            end
            flash[:success] = "Welcome to ZangZing!"
            @new_user.deliver_welcome!
            UserSession.create(@new_user, true)
            session[:show_welcome_dialog] = true
            redirect_back_or_default @new_user
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
           session[:client_dialog]=root_url+'static/inactive_dialog.html'

           redirect_to service_url and return
        end  
      end
      render :action => :new 
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

      @user = User.find_by_username(params[:user][:username])
      if @user == current_user #if the username returns the current user this means its a profile edit
        @user = nil
      end
      render :json => !@user and return

    end
    render :json => true #Invalid call return not valid
  end

  # Used by The Admin Interface to display a list of users
  def index
    @page = "users"
    @users = User.paginate(:page =>params[:page])
  end

  # Used by The Admin Interface to activate de-activate users
  def activate
    @user = User.find(params[:id])
    if @user.active
      @user.deactivate!
    else
      @user.activate!
      @user.deliver_welcome!
    end
    redirect_to :action => :index
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