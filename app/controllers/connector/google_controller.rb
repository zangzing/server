class Connector::GoogleController < Connector::ConnectorController
  require 'gdata'
  before_filter :service_login_required

  NS = {
      "a"  => "http://www.w3.org/2005/Atom",
      "gp" => "http://schemas.google.com/photos/2007",
      "m"  => "http://search.yahoo.com/mrss/",
      "os" => "http://a9.com/-/spec/opensearchrss/1.0/",
      "gd" => "http://schemas.google.com/g/2005"
    }

protected

  def http_timeout
    SERVICE_CALL_TIMEOUT[:google]
  end

  def service_login_required
    unless permanent_token
      @permanent_token = service_identity.credentials
      raise InvalidToken unless @permanent_token
      client.authsub_token = @permanent_token
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_google
  end

  def client
    @client ||= GData::Client::Contacts.new
  end

  def scope
    'http://www.google.com/m8/feeds/ https://picasaweb.google.com/data/feed/'
  end

  def upgrade_access_token!(request_token)
    client.authsub_token = request_token
    SystemTimer.timeout_after(http_timeout) do
      @permanent_token = client.auth_handler.upgrade()
    end
    client.authsub_token = @permanent_token
  end
  
  def permanent_token
    @permanent_token
  end

  def permanent_token=(new_token)
    @permanent_token = new_token
    client.authsub_token = new_token
  end

end
