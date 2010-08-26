class Connector::ProxyController < ApplicationController
  before_filter :require_user

  #todo: need to restrict what we allow to be proxied. should probably just be smugmug
  #todo: should use nginx redirect header for production
  def proxy
    #todo: should stream this
    url = params[:url]
    bin_io = OpenURI.send(:open, url)
    send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
  end
end





