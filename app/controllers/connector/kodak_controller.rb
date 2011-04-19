class Connector::KodakController < Connector::ConnectorController
  require "net/http"
  require "uri"

  before_filter :service_login_required

  PHOTO_SIZES = {:thumb => 'photoUriSmallJpeg', :screen => 'photoUriMediumJpeg', :full => 'photoUriFullResJpeg'}
  
  def self.api_from_identity(identity)
    cookies = identity.credentials
    KodakConnector.new(cookies)
  end

protected

  def http_timeout
    SERVICE_CALL_TIMEOUT[:kodak]
  end

  def login(email, password)
    raise InvalidCredentials unless connector.sign_in(email, password)
    service_identity.update_attribute(:credentials, connector.auth_token)
  end

  def logout
    connector.auth_token = nil
    service_identity.update_attribute(:credentials, nil)
  end

  def service_login_required
    unless kodak_cookies
      cookies = service_identity.credentials
      raise InvalidToken unless KodakConnector.verify_cookie_as_authenticated(cookies)
      connector.auth_token = cookies
    end
  end

  def connector
    @kodak_connector ||= KodakConnector.new
  end

  def kodak_cookies
    connector.auth_token
  end

  def service_identity
    @service_identity ||= current_user.identity_for_kodak
  end

  def self.make_source_guid(photo_info)
    "kodak_"+Photo.generate_source_guid(photo_info[PHOTO_SIZES[:full]])
  end
  
end