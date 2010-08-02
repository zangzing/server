class SmugmugSessionsController < SmugmugController
  skip_before_filter :service_login_required, :only => [:new, :create]

  def new
    request_token = smugmug_api.consumer.get_request_token
    auth_url = smugmug_api.get_authorize_url(request_token, :access => :Full)
    redirect_to auth_url
  end

  def create
    begin
      smugmug_api.create_access_token!(params[:oauth_token], params[:oauth_token_secret], true)
    rescue => e
      raise InvalidToken if e.kind_of?(SmugmugError)
    end
    raise InvalidCredentials unless smugmug_api.access_token
    token_store.store_token(smugmug_api.access_token(true) , current_user.id)
  end

  def destroy
    token_store.delete_token(current_user.id)
    smugmug_api = nil
  end
end
