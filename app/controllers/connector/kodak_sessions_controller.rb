class Connector::KodakSessionsController < Connector::KodakController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new; end

  def create
    login(params[:email], params[:password])
  end

  def destroy
    logout
  end

end