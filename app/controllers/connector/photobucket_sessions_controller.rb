class Connector::PhotobucketSessionsController < Connector::PhotobucketController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    request_token = photobucket_api.consumer.get_request_token(:oauth_callback => create_photobucket_session_url)
    auth_url = photobucket_api.get_authorize_url(request_token)
    redirect_to auth_url
  end

  def create
    begin
      photobucket_api.create_access_token!(params[:oauth_token], params[:extra], true) #oauth_token_secret is in 'extra' parameter
    rescue => e
      raise InvalidToken if e.kind_of?(PhotobucketError)
    end
    raise InvalidCredentials unless photobucket_api.access_token
    service_identity.update_attribute(:credentials, photobucket_api.access_token(true))
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    photobucket_api = nil
  end
end
