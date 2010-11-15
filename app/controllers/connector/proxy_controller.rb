class Connector::ProxyController < ApplicationController
#  before_filter :require_user

  #todo: need to restrict what we allow to be proxied. should probably just be smugmug
  #todo: should use nginx redirect header for production
  def proxy
    #todo: should stream this
    url = params[:url]
    if %w(production eysandbox sandbox).include?(RAILS_ENV)
      #x_accel_redirect url, :disposition => 'inline'
      response.headers['X-Accel-Redirect'] = url
      render :nothing => true
    else
      bin_io = OpenURI.send(:open, url)
      send_data bin_io.read, :type => bin_io.meta['content-type'], :disposition => 'inline'
    end
  end
end





