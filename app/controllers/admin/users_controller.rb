class Admin::UsersController < Admin::AdminController

 # Used by The Admin Interface to display a list of users
  def index
    @page = "users"
    if session[:last_user_page]
      params[:page] = session[:last_user_page]
      session[:last_user_page] = nil
      params[:search] = session[:last_user_search]
      session[:last_user_search] = nil
    end
    
    if params[:search]
      @users = User.where('email LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR username LIKE ?',
                          "%#{params[:search]}%", "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%").paginate(:page =>params[:page])
    else
      @users = User.paginate(:page =>params[:page])
    end
  end


 # Used by The Admin Interface to activate de-activate users
  def activate
    @user = User.find(params[:id])
    if @user.active
      @user.deactivate!
    else
      @user.activate!
      @user.deliver_welcome!
      SystemSetting[:new_users_allowed] -= 1 if SystemSetting[:new_users_allowed]
    end
    redirect_to :back
  end

  def show
    @user = User.find(params[:id])
  end
end
