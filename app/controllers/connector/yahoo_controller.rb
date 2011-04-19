class Connector::YahooController < Connector::ConnectorController
  before_filter :service_login_required

  def self.api_from_identity(identity)
    YahooConnector.new(identity.credentials)
  end

protected

  def service_login_required
    unless yahoo_auth_token_string
      begin
        @token_string = service_identity.credentials
        @api = YahooConnector.new(@token_string)
        @api.current_user_guid #Aimed to check if token is not expired
      rescue => exception
        raise InvalidToken if exception.kind_of?(YahooError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end



  def service_identity
    @service_identity ||= current_user.identity_for_yahoo
  end

  def owner_info
    @owner
  end

  def yahoo_api
    @api ||= YahooConnector.new
  end

  def yahoo_api=(api)
    @api = api
  end

  def yahoo_auth_token_string
    @token_string
  end

end
