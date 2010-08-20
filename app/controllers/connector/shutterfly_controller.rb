class Connector::ShutterflyController < Connector::ConnectorController
  before_filter :service_login_required

  PHOTO_SIZES = {:thumb => '1', :screen => '2', :full => '3'}

  attr_accessor :sf_user_token

  def initialize(*args)
    super(*args)
    ShutterflyConnector.app_id = SHUTTERFLY_API_KEYS[:app_id]
    ShutterflyConnector.shared_secret = SHUTTERFLY_API_KEYS[:shared_secret]
  end

  protected

  def service_login_required
    unless sf_user_token
      begin
        @sf_user_token = service_identity.credentials
        authtoken, usertoken = @sf_user_token.split('_')
        @api = ShutterflyConnector.new(usertoken, authtoken)
        Shutterfly_api.call_method('Shutterfly.auth.checkAccessToken')
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
    @api ||= ShutterflyConnector.new
  end

  def sf_api=(api)
    @api = api
  end

  def get_photo_url(photo_id, size_wanted)
    img_id = photo_id.dup
    img_id[35] = PHOTO_SIZES[size_wanted]
    "http://im1.shutterfly.com/proctaserv/#{img_id}"
  end

end
