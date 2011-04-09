class Connector::SmugmugSessionsController < Connector::SmugmugController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new
    request_token = smugmug_api.consumer.get_request_token
    auth_url = smugmug_api.get_authorize_url(request_token, :access => :Full)
    redirect_to auth_url
  end

  def create
    begin
      SystemTimer.timeout_after(http_timeout) do
        smugmug_api.create_access_token!(params[:oauth_token], params[:oauth_token_secret], true)
      end
    rescue => e
      raise InvalidToken if e.kind_of?(SmugmugError)
    end
    raise InvalidCredentials unless smugmug_api.access_token
    service_identity.update_attribute(:credentials, smugmug_api.access_token(true))
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    smugmug_api = nil
  end
end
