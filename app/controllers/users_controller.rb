class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :edit, :update, :destroy]
  before_filter :admin_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]


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
      unless SystemSetting[:allow_everyone]
        @new_user.active = false
        guest = Guest.find_by_email( params[:user][:email] )
        if guest
           if SystemSetting[:always_allow_beta_listers] && guest.beta_lister?
              @new_user.active = true #no more users but always allow beta lister is set and user is beta_lister
           else
              if SystemSetting[:new_users_allowed] > 0
                # user allotment available
                if guest.share?
                  if SystemSetting[:allow_shares]
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
           flash[:notice] = "Beta Signup is open to guests only. We will evaluate your signup request and email you when your account is ready"
           redirect_to root_url and return
        end  
      end
      render :action => :new 
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