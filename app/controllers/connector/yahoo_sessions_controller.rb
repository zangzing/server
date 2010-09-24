class Connector::YahooSessionsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]


  def new
    request_token = yahoo_api.consumer.get_request_token #(:oauth_callback => "#{create_yahoo_session_url}/")
    auth_url = yahoo_api.get_authorize_url(request_token, :callback => "#{create_yahoo_session_url}/")
    redirect_to auth_url
  end

  def create
    begin
      yahoo_api.create_access_token!(params[:oauth_token], params[:oauth_token_secret], true)
    rescue => e
      raise InvalidToken if e.kind_of?(YahooError)
    end
    raise InvalidCredentials unless yahoo_api.access_token
    service_identity.update_attribute(:credentials, yahoo_api.access_token(true))
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    yahoo_api = nil
  end


end
