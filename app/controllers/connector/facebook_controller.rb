class Connector::FacebookController < Connector::ConnectorController
  require 'hyper_graph'

  PHOTO_SIZES = {:thumb => 'album', :screen => 'normal', :full => 'normal'} #Possible types are thumbnail, album, normal

  before_filter :service_login_required

protected

  def service_login_required
        @graph ||= service_identity.facebook_graph
  end

  def service_identity
    @service_identity ||= current_user.identity_for_facebook
  end

  def facebook_graph
    @graph ||= service_identity.facebook_graph
  end


  def get_photo_url(photo_id, size)
    url = URI.escape("/#{photo_id}/picture?access_token=#{facebook_auth_token}&type=#{size}")
    http = Net::HTTP.new(HyperGraph::API_URL, 443) 
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.get(url)
    response['Location']
  end

  def compose_photo_url(photo_info, size)
    url = photo_info[:source]
    url.gsub(/_n\./, "_#{size[0,1]}.")
  end


end
