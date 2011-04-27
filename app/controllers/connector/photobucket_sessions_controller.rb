class Connector::PhotobucketSessionsController < Connector::PhotobucketController
  skip_before_filter :service_login_required, :only => [:new, :create, :destroy]
#  skip_before_filter :require_user, :only => [:new, :create, :destroy]

  def new
    request_token = photobucket_api.consumer.get_request_token(:oauth_callback => create_photobucket_session_url)
    auth_url = photobucket_api.get_authorize_url(request_token)
    redirect_to auth_url
  end

  def create
    if params[:status]=='denied'
      @error = 'You must grant access to import your photos'
    else
      begin
        SystemTimer.timeout_after(http_timeout) do
          photobucket_api.create_access_token!(params[:oauth_token], params[:extra], true) #oauth_token_secret is in 'extra' parameter
        end
        service_identity.update_attribute(:credentials, photobucket_api.access_token(true))
      rescue PhotobucketError => e
        @error = e.reason
      end
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    photobucket_api = nil
    render 'connector/sessions/destroy'
  end
end
