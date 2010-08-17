class TwitterController < ConnectorController

  before_filter :service_login_required

  def initialize(*args)
    super(*args)
    TwitterConnector.api_key = TWITTER_API_KEYS[:app_key]
    TwitterConnector.shared_secret = TWITTER_API_KEYS[:consumer_secret]
  end

  protected

  def service_login_required
    unless twitter_auth_token_string
      begin
        @token_string = service_identity.credentials
        @api = TwitterConnector.new(@token_string)
      rescue => exception
        raise InvalidToken if exception.kind_of?(TwitterError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_twitter
  end

  def twitter_api
    @api ||= TwitterConnector.new
  end

  def twitter_api=(api)
    @api = api
  end

  def twitter_auth_token_string
    @token_string
  end

end
