class Connector::GoogleSessionsController < Connector::GoogleController
  skip_before_filter :require_user, :only => [:new, :create]
  skip_before_filter :service_login_required
  
  def new
    redirect_to GData::Auth::AuthSub.get_url(create_google_session_url, scope, true, true)
  end

  def create
    if params[:token]
      upgrade_access_token!(params[:token])
      service_identity.update_attribute(:credentials, permanent_token)
    else
      @error = 'You must grant access to import your photos'
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    render 'connector/sessions/destroy'
  end

end