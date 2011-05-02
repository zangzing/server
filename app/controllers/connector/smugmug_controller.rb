class Connector::SmugmugController < Connector::ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  def self.api_from_identity(identity)
    api = SmugmugConnector.new(identity.credentials)
    #api.call_method('smugmug.auth.checkAccessToken')
    api
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(SmugmugError) && [35, 36].include?(exception.code)
      InvalidToken.new(exception.reason)
    end
  end


  protected

  def service_login_required
    unless smugmug_auth_token_string
      self.class.call_with_error_adapter do
        @token_string = service_identity.credentials
        @api = SmugmugConnector.new(@token_string)
        @owner = smugmug_api.call_method('smugmug.auth.checkAccessToken')
      end
    end
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
