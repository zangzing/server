class Connector::InstagramSessionsController < Connector::InstagramController

  skip_before_filter :service_login_required, :only => [:new, :create]
  #skip_before_filter :require_user, :only => [:new, :create]

  def new
    url = Instagram.authorize_url(:redirect_uri => create_instagram_session_url)
    redirect_to url
  end

  def create
    if params[:error]
      @error = params[:error_description]
    else  
      response = Instagram.get_access_token(params[:code], :redirect_uri => create_instagram_session_url)
      service_identity.update_attribute(:credentials, response.access_token)
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    render 'connector/sessions/destroy'
  end


end
