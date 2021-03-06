class Connector::GoogleController < Connector::ConnectorController
  require 'gdata'

  NS = {
      "a"  => "http://www.w3.org/2005/Atom",
      "gp" => "http://schemas.google.com/photos/2007",
      "m"  => "http://search.yahoo.com/mrss/",
      "os" => "http://a9.com/-/spec/opensearchrss/1.0/",
      "gd" => "http://schemas.google.com/g/2005"
    }

protected

  def self.api_from_identity(identity)
    api = self.create_client
    unless identity.credentials.blank?
      api.authsub_token = identity.credentials
      api.authsub_private_key = "#{Rails.root}/config/certs/gmail/private_key.pem"
    end
    api
  end

  def self.moderate_exception(exception)
    case exception
      when
        GData::Client::AuthorizationError,
        GData::Client::Error,
        GData::Client::CaptchaError
          then InvalidToken.new(exception.message)
      when
        GData::Client::ServerError,
        GData::Client::UnknownError,
        GData::Client::VersionConflictError,
        GData::Client::RequestError,
        GData::Client::BadRequestError
          then HttpCallFail
      else nil
    end
  end


  def self.create_client
    GData::Client::Contacts.new
  end

  def service_login_required
    unless permanent_token
      @permanent_token = service_identity.credentials
      raise InvalidToken unless @permanent_token
      client.authsub_token = @permanent_token
      client.authsub_private_key = "#{Rails.root}/config/certs/gmail/private_key.pem"
    end
  end

  def service_identity
    @service_identity ||= current_user.identity_for_google
  end

  def client
    @client ||= self.class.create_client
  end

  def scope
    'http://www.google.com/m8/feeds/ https://picasaweb.google.com/data/feed/'
  end

  def upgrade_access_token!(request_token)
    client.authsub_token = request_token
    SystemTimer.timeout_after(http_timeout) do
      client.auth_handler.private_key = "#{Rails.root}/config/certs/gmail/private_key.pem"
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
