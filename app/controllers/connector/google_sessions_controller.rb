class Connector::GoogleSessionsController < Connector::GoogleController

  def new
    redirect_to GData::Auth::AuthSub.get_url(create_google_session_url, scope)
  end

  def create
    if params[:token]
      upgrade_access_token!(params[:token])
      service_identity.update_attribute(:credentials, permanent_token)
    end
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
  end

end