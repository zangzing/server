class Connector::KodakSessionsController < Connector::KodakController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new;

  end

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        login(params[:email], params[:password])
      end
    rescue Exception => ex
      flash.now[:error] = ex.message
      render "new"
    end
  end

  def destroy
    logout
  end

end