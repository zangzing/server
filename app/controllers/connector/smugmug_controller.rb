class Connector::SmugmugController < Connector::ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  before_filter :service_login_required
  
  def self.api_from_identity(identity)
    api = SmugmugConnector.new(identity.credentials)
    #api.call_method('smugmug.auth.checkAccessToken')
    api
  end

  protected

  def service_login_required
    unless smugmug_auth_token_string
      begin
        @token_string = service_identity.credentials
        @api = SmugmugConnector.new(@token_string)
        @owner = smugmug_api.call_method('smugmug.auth.checkAccessToken')
      rescue => exception
        raise InvalidToken if exception.kind_of?(SmugmugError)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def http_timeout
    SERVICE_CALL_TIMEOUT[:smugmug]
  end

  def service_identity
    @service_identity ||= current_user.identity_for_smugmug
  end

  def owner_info
    @owner
  end

  def smugmug_api
    @api ||= SmugmugConnector.new
  end

  def smugmug_api=(api)
    @api = api
  end

  def smugmug_auth_token_string
    @token_string
  end

  def self.make_source_guid(photo_info)
    "smugmug_"+Photo.generate_source_guid(photo_info[:originalurl])
  end

end
