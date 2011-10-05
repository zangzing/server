class Connector::KodakSessionsController < Connector::KodakController
  skip_before_filter :service_login_required, :only => [:new, :create, :destroy]
  skip_before_filter :require_user, :only => [:new, :create]

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        login(params[:email], params[:password])
      end
      render 'connector/sessions/create'
    rescue Exception => ex
      flash.now[:error] = ex.message
      render "new"
    end
  end

  def destroy
    logout
    render 'connector/sessions/destroy'
  end

end