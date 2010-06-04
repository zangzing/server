class UsersController < ApplicationController
  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  before_filter :not_signed_in_user, :only => [:new, :create]

  def new
      @user = User.new
      @title = "Sign up"
  end
  
  
  def show
      @user = User.find(params[:id])
      @albums = @user.albums.paginate(:page => params[:page])
      @title = CGI.escapeHTML(@user.name)
  end
  
  def create
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to ZangZing!"
        redirect_to @user
      else
        @title = "Sign up"
        render 'new'
      end
  end
  
  def edit 
    @user = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
    logger.debug "The params hash in update is is #{params.inspect}"
    if @user.update_attributes( params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title ="Edit user"
      render 'edit'
    end
  end
  
  def index
    @title = "All users"
    @users = User.paginate(:page =>params[:page])
  end
  
  def destroy
     user = User.find(params[:id])
    if user == current_user && user.admin? then
      flash[:notice] ="Unable to destroy self. Ask other admin to do it"
    else
      user.destroy
      flash[:success] ="User Deleted"
    end
    redirect_to users_path
  end
  
  
  private
   
    def correct_user
      @user = User.find(params[:id])
      redirect_to( root_path ) unless current_user?(@user)
    end
    def admin_user
          redirect_to( root_path ) unless current_user.admin?
    end
    def not_signed_in_user
      redirect_to( root_path ) unless !signed_in?
    end
    
end