class Admin::AdminController < ApplicationController
  before_filter :admin_login_required

  def admin_login_required
    unless current_user && current_user.admin?
        store_location
        flash[:notice] = "You must be logged in as an administrator to access this page"
        redirect_to new_user_session_url
        return false
    end
  end
end