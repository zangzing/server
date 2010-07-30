class KodakSessionsController < KodakController
  skip_before_filter :login_required, :only => [:new, :create]

  def new; end

  def create
    login(params[:email], params[:password])
  end

  def destroy
    logout
  end

end
