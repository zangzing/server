class Connector::TwitterController < Connector::ConnectorController
  require 'twitter_connector'

  def initialize(*args)
    super(*args)
    TwitterConnector.api_key = TWITTER_API_KEYS[:app_key]
    TwitterConnector.shared_secret = TWITTER_API_KEYS[:consumer_secret]
  end

  protected

  def http_timeout
    SERVICE_CALL_TIMEOUT[:twitter]
  end

  def service_login_required
    @api = service_identity.twitter.api
  end

  def service_identity
    @service_identity ||= current_user.identity_for_twitter
  end

  def twitter_api
    @api ||= TwitterConnector.new
  end
end
