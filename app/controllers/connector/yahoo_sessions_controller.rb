class Connector::YahooSessionsController < Connector::YahooController
  skip_before_filter :service_login_required, :only => [:new, :create, :destroy]
  skip_before_filter :require_user, :only => [:new, :create]


  def new
    request_token = yahoo_api.consumer.get_request_token(:oauth_callback => "#{create_yahoo_session_url}/")
    session[:yahoo_request_token_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        yahoo_api.create_access_token!(params[:oauth_token], session[:yahoo_request_token_secret], true, params[:oauth_verifier])
      end
      service_identity.update_attribute(:credentials, yahoo_api.access_token(true))
    rescue YahooError => e
      @error = e.reason
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    yahoo_api = nil
    render 'connector/sessions/destroy'
  end


end
