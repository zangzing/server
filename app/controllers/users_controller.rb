class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:index, :edit, :update, :destroy]
  before_filter :admin_user, :only => :destroy
  before_filter :correct_user, :only => [:edit, :update]


  def new
      @title = "Sign up"
      @user = User.new
  end

  def create    
      @user = User.new(params[:user])

      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      
      # User activation was disabled  
      #if @user.save_without_session_maintenance
      #   @user.deliver_activation_instructions!
      #   flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      #   redirect_to root_url
         
      if @user.save
            flash[:success] = "Welcome to ZangZing!"
            @user.deliver_welcome!
            redirect_back_or_default @user
      else
         render :action => :new
      end
  end
  
  def show
      @user = User.find(params[:id]) 
      redirect_to  user_albums_path(@user )
  end
  
  def edit 
    @title = "Edit user"
    @user = @current_user    
    render :layout => false
  end
  
  def update
    @user = current_user
    if @user.update_attributes( params[:user])
      flash[:notice] = "Your Profile Has Been Updated."
      respond_to do |format|
          format.html  { redirect_to @user   }
          format.json { render :json => "", :status => 200 and return }
       end
    else
      respond_to do |format|
          format.html  { render :action => :edit   }
          format.json  { errors_to_headers( @user )
                         render :json => "", :status => 400 and return}
       end
    end
  end
  
  def index
    @title = "All users"
    @users = User.paginate(:page =>params[:page])
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
      render :json => !@user and return
    end
    render :json => true #Invalid call return not valid
  end

  def validate_username

    if params[:user] && params[:user][:username]

      @user = User.find_by_username(params[:user][:username])
      if @user == current_user #if the email returns the current user this means its a profile edit
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