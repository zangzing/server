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
      if @user.save
        flash[:success] = "Welcome to ZangZing!"
        redirect_back_or_default @user
      else
        render :action => :new
      end
  end
  
  def show
      @user = User.find(params[:id])
      @albums = @user.albums.paginate(:page => params[:page])
      @title = CGI.escapeHTML(@user.name)
  end
  
  def edit 
    @title = "Edit user"
    @user = @current_user    
  end
  
  def update
    @user = @current_user
    if @user.update_attributes( params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title ="Edit user"
      render :action => :edit 
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
  

  private
    def admin_user
          redirect_to( root_path ) unless current_user.admin?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to( root_path ) unless current_user?(@user)
    end

    
end