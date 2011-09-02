class Connector::DropboxUrlsController < Connector::DropboxController
  #Parameters to delegate to the Dropbox API
  PARAMS_TO_DELEGATE = [:size]

  def serve_image
    api = dropbox_api
    opts = {:root => params[:root]}
    PARAMS_TO_DELEGATE.each do |api_param|
      opts[api_param] = params[api_param] if params[api_param]
    end
    signed_url = self.class.make_signed_url(api.access_token, params[:path], opts)
    redirect_to signed_url
  end
  
  #For GeneralImport's custom url maker method
  def self.get_file_signed_url(photo, source_url)
    user = User.find(photo.user_id)
    identity = user.identity_for_dropbox
    if identity
      api = api_from_identity(identity)
      return make_signed_url(api.access_token, source_url, :root => 'files')
    end
  end


end
