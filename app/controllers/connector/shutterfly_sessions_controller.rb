class Connector::ShutterflySessionsController < Connector::ShutterflyController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    url = sf_api.generate_authorization_url(:callback_url => create_shutterfly_session_url)
    redirect_to url
  end

  def create
    if params[:oflyUserAuthToken] && params[:oflyUserid]
      sf_user_token = "#{params[:oflyUserAuthToken]}_#{params[:oflyUserid]}"
      service_identity.update_attribute(:credentials, sf_user_token)
    else
      @error = 'Parameters required to authenticate are missing.\nPlease report this issue to ZangZing support.'
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    sf_user_token = nil
    sf_api = nil
    render 'connector/sessions/destroy'
  end
end
