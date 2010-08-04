class ShutterflyController < ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  before_filter :service_login_required

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
        @sf_user_token = token_store.get_token(current_user.id)
        authtoken, usertoken = @sf_user_token.split('_')
        @api = ShutterflyConnector.new(usertoken, authtoken)
        #Shutterfly_api.call_method('Shutterfly.auth.checkAccessToken')
      rescue => exception
        raise InvalidToken if exception.kind_of?(ShutterflyError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def token_store
    @token_store ||= TokenStore.new(:shutterfly, session)
  end

  def sf_api
    @api ||= ShutterflyConnector.new
  end

  def sf_api=(api)
    @api = api
  end

end
