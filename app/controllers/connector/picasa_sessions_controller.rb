class Connector::PicasaSessionsController < Connector::PicasaController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new
    redirect_to GData::Auth::AuthSub.get_url(create_picasa_session_url, scope)
  end

  def create
    upgrade_access_token!(params[:token])
    service_identity.update_attribute(:credentials, permanent_token)
  end

  def destroy
    client.auth_handler.revoke
    service_identity.update_attribute(:credentials, nil)
  end

end