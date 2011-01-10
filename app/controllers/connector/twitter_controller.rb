class Connector::TwitterController < Connector::ConnectorController
  require 'twitter_connector'
  
  before_filter :service_login_required

  def initialize(*args)
    super(*args)
    TwitterConnector.api_key = TWITTER_API_KEYS[:app_key]
    TwitterConnector.shared_secret = TWITTER_API_KEYS[:consumer_secret]
  end

  protected

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
