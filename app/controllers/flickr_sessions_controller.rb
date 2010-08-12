class FlickrSessionsController < FlickrController
  skip_before_filter :service_login_required, :only => [:new, :create]
  skip_before_filter :require_user, :only => [:new, :create]

  def new
    frob = flickr_api.auth.getFrob
    auth_url = FlickRaw.auth_url :frob => frob, :perms => 'read'
    redirect_to auth_url
  end

  def create
    begin
      auth = flickr_api.auth.getToken :frob => params[:frob]
      service_identity.update_attribute(:credentials, auth.token)
    rescue => e
      raise InvalidCredentials if e.kind_of?(FlickRaw::FailedResponse)
    end
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    flickr_api = nil
  end


end
