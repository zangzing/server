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
        @guest = Guest.find_by_email( params[:user][:email] )
        if @guest
           if SystemSetting[:always_allow_beta_listers] && @guest.beta_lister?
              @new_user.active = true #always allow when beta-lister is set and user is beta_lister
           else
              if SystemSetting[:new_users_allowed] > 0
                # user allotment available
                if @guest.share?
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

           redirect_to root_url and return
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


  # table-less model class so that we can use form helpers
  class ChangePassword < ActiveRecord::Base
    class_inheritable_accessor :columns

    def self.columns()
      @columns ||= [];
    end

    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    column :old_password, :string
    column :password, :string
    column :confirm_password, :string
  end



  def edit_password
    @user = current_user
    @change_password = ChangePassword.new
  end

  def update_password
    @user = current_user

    @change_password = ChangePassword.new

    if params[:users_controller_change_password][:password] != params[:users_controller_change_password][:confirm_password]

      @change_password.errors[:password] = "Passwords don't match"
      @change_password.errors[:confirm_password] = "Passwords don't match"

      render :action => :edit_password
    else
      @user.old_password = params[:users_controller_change_password][:old_password]
      @user.password = params[:users_controller_change_password][:password]
      if !@user.save
        @change_password.errors.replace(@user.errors)
        render :action => :edit_password
      else
        redirect_to user_pretty_url(@user)
      end
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