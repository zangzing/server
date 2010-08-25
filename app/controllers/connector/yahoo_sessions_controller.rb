class Connector::YahooSessionsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new; end

  def create
    store_login_data(params[:login], params[:password])
    service_login_required #To check credentials
  end

  def destroy
    wipe_login_data!
  end

end
