class KodakController < ConnectorController
  require "net/http"
  require "uri"
  require 'xmlsimple'

  before_filter :service_login_required

  PHOTO_SIZES = {:thumb => 'photoUriThumbJpeg', :screen => 'photoUriMediumJpeg', :full => 'photoUriFullResJpeg'}
  
  def initialize(*args)
    super(*args)
    @kodak_connector = KodakConnector.new
  end
  

protected

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
      @kodak_connector.auth_token = cookies
    end
  end

  def connector
    @kodak_connector
  end

  def kodak_cookies
    @kodak_connector.auth_token
  end

  def service_identity
    @service_identity ||= current_user.identity_for_kodak
  end

end