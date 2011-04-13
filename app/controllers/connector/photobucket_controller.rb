class Connector::PhotobucketController < Connector::ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  before_filter :service_login_required

  def self.api_from_identity(identity)
    PhotobucketConnector.new(identity.credentials)
  end

protected

  def service_login_required
    unless auth_token_string
      begin
        @token_string = service_identity.credentials
        @api = PhotobucketConnector.new(@token_string)
      rescue => exception
        raise InvalidToken if exception.kind_of?(PhotobucketError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def http_timeout
    SERVICE_CALL_TIMEOUT[:photobucket]
  end

  def service_identity
    @service_identity ||= current_user.identity_for_photobucket
  end

  def photobucket_api
    @api ||= PhotobucketConnector.new
  end

  def photobucket_api=(api)
    @api = api
  end

  def auth_token_string
    @token_string
  end

  def self.make_source_guid(url)
    "photobucket_"+Photo.generate_source_guid(url)
  end

  
end
