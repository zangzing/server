class Connector::KodakController < Connector::ConnectorController
  require "net/http"
  require "uri"

  PHOTO_SIZES = {:thumb => 'photoUriSmallJpeg', :screen => 'photoUriMediumJpeg', :full => 'photoUriFullResJpeg'}
  
  def self.api_from_identity(identity)
    cookies = identity.credentials
    KodakConnector.new(cookies)
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(KodakError)
      InvalidToken.new(exception.reason)
    else
      nil
    end
  end


protected


  def login(email, password)
    raise InvalidToken.new('Credentials entered are invalid') unless connector.sign_in(email, password)
    service_identity.update_attribute(:credentials, connector.auth_token)
  end

  def logout
    connector.auth_token = nil
    service_identity.update_attribute(:credentials, nil)
  end

  def service_login_required
    unless kodak_cookies
      cookies = service_identity.credentials
      raise InvalidToken.new('Stored credentials are no longer valid') unless KodakConnector.verify_cookie_as_authenticated(cookies)
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