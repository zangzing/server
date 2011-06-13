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
    if @user == current_user
        flash[:error] = "Sorry, cannot activate/deactivate currently logged in admin user, ask another admin to do it"
        redirect_to :back and return
   end
    if @user.active
      @user.deactivate!
      flash[:notice] = "User Account Deactivated!"
    else
      @user.activate!
      @user.deliver_welcome!
      flash[:notice] = "User Account Now Active. Welcome Email Delivered!"      
      SystemSetting[:new_users_allowed] -= 1 if SystemSetting[:new_users_allowed]
    end
    redirect_to :back
  end


  # Used by The Admin Interface to send password reset emails
  def reset_password
   @user = User.find(params[:id])
   if @user == current_user
        flash[:error] = "Sorry, cannot reset password for currently logged in admin user, ask another admin to do it"
        redirect_to :back and return
   end
   if @user
         @user.deliver_password_reset_instructions!
         flash[:notice] = "Reset-Password Email Sent!"
   else
        flash[:error] = "Sorry, we could not find that email address in our records"
   end
    redirect_to :back
  end


  # Displays the detailed view for one user.
  def show
    @page = "users"
    @user = User.find(params[:id])
    GeoIp.api_key = "b3be65bc4b850a03cc12200100937debca7a842d9afc7ae40394d1d823c22cae"
    if @user.current_login_ip
      @current_login_ip_info = false
      #@current_login_ip_info = GeoIp.geolocation(@user.current_login_ip)
    end
    if @user.last_login_ip
      @last_login_ip_info = false
      #@last_login_ip_info = GeoIp.geolocation(@user.last_login_ip)
    end
    @agent = Agent.where(:user_id => @user.id).order('authorized_at DESC').first
  end
end
