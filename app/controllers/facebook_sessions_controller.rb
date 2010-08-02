class FacebookSessionsController < FacebookController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new
    auth_url = HyperGraph.authorize_url(FACEBOOK_API_KEYS[:app_id], create_facebook_session_url(:host => APPLICATION_HOST), :scope => 'user_photos', :display => 'popup')
    redirect_to auth_url
  end

  def create
    token = HyperGraph.get_access_token(FACEBOOK_API_KEYS[:app_id], FACEBOOK_API_KEYS[:app_secret], create_facebook_session_url(:host => APPLICATION_HOST), params[:code])
    raise InvalidCredentials unless token
    token_store.store_token(token, current_user.id)
  end

  def destroy
    token_store.delete_token(current_user.id)
    facebook_graph = nil
  end

end
