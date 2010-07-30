class FacebookController < ConnectorController
  require 'token_store'

  PHOTO_SIZES = {:thumb => 'thumbnail', :screen => 'normal', :full => 'normal'} #Possible types are thumbnail, album, normal

  before_filter :login_required

  def token #TODO Remove this method
    render :text => @access_token
  end

protected

  def login_required
    unless facebook_auth_token
      begin
        @access_token = token_store.get_token(current_user.id)
        @graph = HyperGraph.new(facebook_auth_token)
      rescue => exception
        #TODO Un-comment all error handling stuff
        #raise InvalidToken if exception.kind_of?(FacebookError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def token_store
    @token_store ||= TokenStore.new(:facebook, session)
  end

  def facebook_graph
    @graph ||= HyperGraph.new(facebook_auth_token)
  end

  def facebook_graph=(val)
    @graph = val
  end

  def facebook_auth_token
    @access_token
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
