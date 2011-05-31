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


end
