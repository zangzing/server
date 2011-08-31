class Connector::DropboxSessionsController < Connector::DropboxController

  def new
    service_identity.credentials = nil
    dropbox_api.mode = :metadata_only
    session[:dropbox_session] = dropbox_api.serialize
    auth_url = dropbox_api.authorize_url(:oauth_callback => create_dropbox_session_url)
    redirect_to auth_url
  end

  def create
    if params[:oauth_token] then
      begin
        dropbox_api = Dropbox::Session.deserialize(session[:dropbox_session])
        SystemTimer.timeout_after(http_timeout) do
          dropbox_api.authorize(params)
          service_identity.update_attribute(:credentials, dropbox_api.serialize)
          session[:dropbox_session] = nil
        end
      rescue Exception => e
        @error = e.message
      end
    else
      @error = 'You must grant access to import your photos'
    end
    render 'connector/sessions/create'
  end

  def destroy
    service_identity.update_attribute(:credentials, nil)
    dropbox_api = nil
    render 'connector/sessions/destroy'
  end

end
