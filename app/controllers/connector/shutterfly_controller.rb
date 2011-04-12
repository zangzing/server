class Connector::ShutterflyController < Connector::ConnectorController
  before_filter :service_login_required

  PHOTO_SIZES = {:thumb => '1', :screen => '2', :full => '3'}

  attr_accessor :sf_user_token

  def self.api_from_identity(identity)
    unless identity.credentials.nil?
      authtoken, usertoken = identity.credentials.split('_')
      ShutterflyConnector.new(usertoken, authtoken)
    else
      ShutterflyConnector.new
    end
  end

  def self.http_timeout
    SERVICE_CALL_TIMEOUT[:shutterfly]
  end

  def self.get_photo_url(photo_id, size_wanted)
    img_id = photo_id.dup
    img_id[35] = PHOTO_SIZES[size_wanted]
    "http://im1.shutterfly.com/proctaserv/#{img_id}"
  end

  def self.make_source_guid(photo_info)
    "shutterfly_"+Photo.generate_source_guid(get_photo_url(photo_info[:id], :full))
  end


protected

  def service_login_required
    unless sf_user_token
      begin
        @sf_user_token = service_identity.credentials
        @api = self.class.api_from_identity(service_identity)
      rescue => exception
        raise InvalidToken if exception.kind_of?(ShutterflyError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
      raise InvalidToken unless @sf_user_token
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_shutterfly
  end

  def sf_api
    @api ||= self.class.api_from_identity(service_identity)
  end

  def sf_api=(api)
    @api = api
  end

  
end
