class Connector::TwitterSessionsController < Connector::TwitterController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    request_token = twitter_api.consumer.get_request_token
    auth_url = twitter_api.get_authorize_url(request_token, :oauth_callback => create_twitter_session_url)
    redirect_to auth_url
  end

  def create
    begin
      twitter_api.create_access_token!(params[:oauth_token], true)
    rescue => e
      raise InvalidToken if e.kind_of?(TwitterError) 
    end
    raise InvalidCredentials unless twitter_api.access_token
    service_identity.update_attribute(:credentials, twitter_api.access_token(true))
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    twitter_api = nil
  end
end
