class Connector::ProxyController < ApplicationController
#  before_filter :require_user

  #todo: need to restrict what we allow to be proxied. should probably just be smugmug
  #todo: should use nginx redirect header for production
  def proxy
    #now that we rely on nginx, all requests are proxied by nginx so we
    #don't have to serve the request up slowly from Rails
    url = params[:url]
    uri = URI.parse(url)
    response.headers['X-Accel-Redirect'] = "/nginx_redirect/#{uri.host}#{uri.path}"
    render :nothing => true
  end
end





