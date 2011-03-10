class Connector::InstagramController < Connector::ConnectorController

  before_filter :service_login_required

  Instagram.configure do |config|
    config.client_id = INSTAGRAM_API_KEYS[:client_id]
    config.client_secret = INSTAGRAM_API_KEYS[:client_secret]
  end

protected

  def service_login_required
    unless access_token
      begin
        @token_string = service_identity.credentials
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

  def make_source_guid(photo_info)
    "instagram_"+Photo.generate_source_guid(photo_info[:images][:standard_resolution][:url])
  end

  def http_timeout
    SERVICE_CALL_TIMEOUT[:instagram]
  end

  def feed_owner
    case params[:target]
      when 'my-photos' then 'self'
      else nil
    end
  end


end
