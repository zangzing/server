class FacebookSessionsController < FacebookController
  skip_before_filter :login_required, :only => [:new, :create]

  FACEBOOK_SESSION_CREATE_URL = "http://localhost:3000/facebook/sessions/create"

  def new
    auth_url = HyperGraph.authorize_url(FACEBOOK_API_KEYS[:app_id], FACEBOOK_SESSION_CREATE_URL, :scope => 'user_photos', :display => 'popup')
    redirect_to auth_url
  end

  def create
    token = HyperGraph.get_access_token(FACEBOOK_API_KEYS[:app_id], FACEBOOK_API_KEYS[:app_secret], FACEBOOK_SESSION_CREATE_URL, params[:code])
    raise InvalidCredentials unless token
    puts "TOKEN FROM CONTROLLER ======> #{token}"
    token_store.store_token(token, current_user.id)
  end

  def destroy
    token_store.delete_token(current_user.id)
    facebook_graph = nil
  end

end
