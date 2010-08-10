class GoogleSessionsController < GoogleController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    redirect_to GData::Auth::AuthSub.get_url(create_google_session_url, scope)
  end

  def create
    upgrade_access_token!(params[:token])
    token_store.store_token(permanent_token, current_user.id)
  end

  def destroy
    token_store.delete_token(current_user.id)
    contacts_client.auth_handler.revoke
  end

end