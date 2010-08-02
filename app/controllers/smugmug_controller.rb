class SmugmugController < ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  before_filter :service_login_required

  def initialize(*args)
    super(*args)
    SmugmugConnector.api_key = SMUGMUG_API_KEYS[:api_key]
    SmugmugConnector.shared_secret = SMUGMUG_API_KEYS[:shared_secret]
  end

  protected

  def service_login_required
    unless smugmug_auth_token_string
      begin
        @token_string = token_store.get_token(current_user.id)
        @api = SmugmugConnector.new(@token_string)
        smugmug_api.call_method('smugmug.auth.checkAccessToken')
      rescue => exception
        raise InvalidToken if exception.kind_of?(SmugmugError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def token_store
    @token_store ||= TokenStore.new(:smugmug, session)
  end

  def smugmug_api
    @api ||= SmugmugConnector.new
  end

  def smugmug_api=(api)
    @api = api
  end

  def smugmug_auth_token_string
    @token_string
  end

end
