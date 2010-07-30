class KodakController < ConnectorController
  require "net/http"
  require "uri"
  require 'xmlsimple'
  include ZZ::ConnectorClasses

  before_filter :login_required

  PHOTO_SIZES = {:thumb => 'photoUriThumbJpeg', :screen => 'photoUriMediumJpeg', :full => 'photoUriFullResJpeg'}
  
  def initialize(*args)
    super(*args)
    @kodak_connector = KodakConnector.new
  end
  

protected

  def login(email, password)
    raise InvalidCredentials unless connector.sign_in(email, password)
    token_store.store_token(connector.auth_token, current_user.id)
  end

  def logout
    connector.auth_token = nil
    token_store.delete_token(current_user.id)
  end

  def login_required
    unless kodak_cookies
      cookies = token_store.get_token(current_user.id)
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

  def token_store
    @token_store ||= TokenStore.new(:kodak, session)
  end

end
