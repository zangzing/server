class Connector::TwitterSessionsController < Connector::TwitterController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    request_token = twitter_api.consumer.request_token(:oauth_callback => create_twitter_session_url)
    session[:twitter_request_token_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def create
    begin
      twitter_api.create_access_token!(params[:oauth_token], session[:twitter_request_token_secret], params[:oauth_verifier])
    rescue TwitterError => e
      raise InvalidToken
    end
    service_identity.update_attribute(:credentials, twitter_api.access_token)
    flash[:notice] = "You are now able to share your ZangZing albums through Twitter"
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    twitter_api = nil
  end
end
