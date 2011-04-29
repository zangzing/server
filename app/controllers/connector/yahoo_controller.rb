class Connector::YahooController < Connector::ConnectorController
  before_filter :service_login_required

  def self.api_from_identity(identity)
    YahooConnector.new(identity.credentials)
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(YahooError) && (exception.code/100 == 4) #401, 403, 4xx
      InvalidToken.new(exception.reason.humanize)
    end
  end

protected

  def service_login_required
    unless yahoo_auth_token_string
      self.class.call_with_error_adapter do
        @token_string = service_identity.credentials
        @api = YahooConnector.new(@token_string)
        @api.current_user_guid #Aimed to check if token is not expired
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
