class Connector::InstagramSessionsController < Connector::InstagramController

  skip_before_filter :service_login_required, :only => [:new, :create]
  #skip_before_filter :require_user, :only => [:new, :create]

  def new
    url = Instagram.authorize_url(:redirect_uri => create_instagram_session_url)
    redirect_to url
  end

  def create
    response = Instagram.get_access_token(params[:code], :redirect_uri => create_instagram_session_url)
    raise InvalidToken unless response
    service_identity.update_attribute(:credentials, response.access_token)
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
  end


end
