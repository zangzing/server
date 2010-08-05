class ShutterflySessionsController < ShutterflyController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    url = sf_api.generate_authorization_url(:callback_url => create_shutterfly_session_url)
    redirect_to url
  end

  def create
    sf_user_token = "#{params[:oflyUserAuthToken]}_#{params[:oflyUserid]}"
    raise InvalidCredentials unless sf_user_token
    token_store.store_token(sf_user_token, current_user.id)
  end

  def destroy
    token_store.delete_token(current_user.id)
    sf_user_token = nil
    sf_api = nil
  end
end
