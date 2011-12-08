class Connector::MobilemeSessionsController < Connector::MobilemeController
  skip_before_filter :service_login_required, :only => [:new, :create, :destroy]
  skip_before_filter :require_user, :only => [:new, :create]

  ssl_required :new, :create

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        connector.login(params[:email], params[:password])
        service_identity.update_attribute(:credentials, connector.token)
      end

      redirect_to close_mobileme_session_url

    rescue Exception => ex
      flash.now[:error] = ex.message
      render "new"
    end
  end

  def close
    render 'connector/sessions/close'

  end

  def destroy
    connector.logout
    service_identity.update_attribute(:credentials, nil)
    render 'connector/sessions/destroy'
  end

end
