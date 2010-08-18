class FacebookSessionsController < FacebookController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    auth_url = HyperGraph.authorize_url(FACEBOOK_API_KEYS[:app_id], create_facebook_session_url(:host => APPLICATION_HOST), :scope => 'user_photos,publish_stream,offline_access', :display => 'popup')
    redirect_to auth_url
  end

  def create
    token = HyperGraph.get_access_token(FACEBOOK_API_KEYS[:app_id], FACEBOOK_API_KEYS[:app_secret], create_facebook_session_url(:host => APPLICATION_HOST), params[:code])
    raise InvalidCredentials unless token
    service_identity.update_attribute(:credentials, token)
  end

  def destroy
    service_identity.credentials = nil
    service_identity.update_attribute(:credentials, nil)
  end

end
