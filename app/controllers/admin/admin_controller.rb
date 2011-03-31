class Admin::AdminController < ApplicationController
  before_filter :require_user, :require_admin

  # To be run as a before_filter
  # Will render a 401 page if the currently logged in user is not an admin
  def require_admin
    unless current_user.admin?
      flash[:error] = "Administrator privileges required for this operation"
      response.headers['x_error'] = flash[:error]
      if request.xhr?
        render :status => 401
      else
        render :file => "#{Rails.root}/public/401.html", :layout => false, :status => 401
      end
      return false
    end
  end
end