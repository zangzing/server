class Connector::InstagramController < Connector::ConnectorController

  before_filter :service_login_required

  def self.api_from_identity(identity)
    Instagram.client(:access_token => identity.credentials)
  end

protected

  def service_login_required
    unless access_token
      begin
        @token_string = service_identity.credentials
        raise Instagram::InvalidSignature unless @token_string
        @client = Instagram.client(:access_token => @token_string)
      rescue => exception
        raise InvalidToken if exception.kind_of?(Instagram::InvalidSignature)
        raise HttpCallFail if exception.kind_of?(SocketError) || exception.kind_of?(Instagram::Error)
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
