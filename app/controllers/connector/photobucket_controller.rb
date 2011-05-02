class Connector::PhotobucketController < Connector::ConnectorController

  PHOTO_SIZES = {:thumb => :tinyurl, :screen => :largeurl, :full => :originalurl}

  def self.api_from_identity(identity)
    PhotobucketConnector.new(identity.credentials)
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(PhotobucketError) && exception.code == '7'
      InvalidToken.new(exception.reason)
    end
  end


protected

  def service_login_required
    unless auth_token_string
      self.class.call_with_error_adapter do
        @token_string = service_identity.credentials
        raise InvalidToken.new('OAuth tokem is missing') if @token_string.blank?
        @api = PhotobucketConnector.new(@token_string)
      end
    end
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
