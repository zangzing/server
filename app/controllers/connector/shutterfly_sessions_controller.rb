class Connector::ShutterflySessionsController < Connector::ShutterflyController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new
    url = sf_api.generate_authorization_url(:callback_url => create_shutterfly_session_url)
    redirect_to url
  end

  def create
    sf_user_token = "#{params[:oflyUserAuthToken]}_#{params[:oflyUserid]}"
    raise InvalidCredentials unless sf_user_token
    service_identity.update_attribute(:credentials, sf_user_token)
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    sf_user_token = nil
    sf_api = nil
  end
end
