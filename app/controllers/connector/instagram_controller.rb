class Connector::InstagramController < Connector::ConnectorController

  def self.api_from_identity(identity)
    Instagram.client(:access_token => identity.credentials)
  end

  def self.moderate_exception(exception)
    return InvalidToken.new('Invalid auth token') if exception.kind_of?(Instagram::BadRequest) && exception.message =~ /"access_token"[\w\s]+invalid/i
    case exception
      when
        Instagram::Error,
        Instagram::InvalidSignature
          then InvalidToken.new(exception.message)
    when
        Instagram::BadRequest,
        Instagram::NotFound,
        Instagram::InternalServerError,
        Instagram::ServiceUnavailable
          then HttpCallFail
      else nil
    end
  end


protected

  def service_login_required
    unless access_token
      self.class.call_with_error_adapter do
        @token_string = service_identity.credentials
        raise Instagram::InvalidSignature unless @token_string
        @client = Instagram.client(:access_token => @token_string)
      end
    end
  end


  def service_identity
    @service_identity ||= current_user.identity_for_instagram
  end
  
  def access_token
    @token_string ||= service_identity.credentials
  end

  def client
    @client ||= Instagram.client(:access_token => access_token)
  end

  def self.make_source_guid(photo_info)
    "instagram_"+Photo.generate_source_guid(photo_info[:images][:standard_resolution][:url])
  end



  def self.feed_owner(params)
    case params[:target]
      when 'my-photos' then 'self'
      else params[:target]
    end
  end


end
