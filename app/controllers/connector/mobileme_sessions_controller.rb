class Connector::MobilemeSessionsController < Connector::MobilemeController
  skip_before_filter :service_login_required, :only => [:new, :create, :destroy]
  skip_before_filter :require_user, :only => [:new, :create]

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        connector.login(params[:email], params[:password])
        service_identity.update_attribute(:credentials, connector.auth_cookies)
      end
      render 'connector/sessions/create'
    rescue Exception => ex
      flash.now[:error] = ex.message
      render "new"
    end
  end

  def destroy
    connector.logout
    render 'connector/sessions/destroy'
  end

end
