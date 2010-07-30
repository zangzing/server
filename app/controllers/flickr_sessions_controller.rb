class FlickrSessionsController < FlickrController
  skip_before_filter :login_required, :only => [:new, :create]

  def new
    frob = flickr_api.auth.getFrob
    auth_url = FlickRaw.auth_url :frob => frob, :perms => 'read'
    redirect_to auth_url
  end

  def create
    begin
      auth = flickr_api.auth.getToken :frob => params[:frob]
      token_store.store_token(auth.token, current_user.id)
    rescue => e
      raise InvalidCredentials if e.kind_of?(FlickRaw::FailedResponse)
    end
  end

  def destroy
    token_store.delete_token(current_user.id)
    flickr_api = nil
  end


end
