class FlickrController < ConnectorController
  before_filter :service_login_required

  PHOTO_SIZES = {:thumb => 'Thumbnail', :screen => 'Medium', :full => 'Big'}
  
  def initialize(*args)
    super(*args)
    FlickRaw.api_key = FLICKR_API_KEYS[:api_key]
    FlickRaw.shared_secret = FLICKR_API_KEYS[:shared_secret]
  end

protected

  def service_login_required
    unless flickr_auth_token
      begin
        @flickr_token = token_store.get_token(current_user.id)
        @flickr_auth = flickr.auth.checkToken :auth_token => flickr_auth_token
      rescue => exception
        raise InvalidToken if exception.kind_of?(FlickRaw::FailedResponse)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
    end
  end

  def token_store
    @token_store ||= TokenStore.new(:flickr, session)
  end

  def flickr_api
    @flickr_api ||= FlickRaw::Flickr.new(flickr_auth_token)
  end

  def flickr_api=(val)
    @flickr_api = val
  end


  def flickr_auth_token
    @flickr_token
  end

  def get_photo_url(photo_info, size_wanted = :screen)
    'http://farm%s.static.flickr.com/%s/%s_%s_%s.%s' % [photo_info.farm, photo_info.server, photo_info.id, photo_info.secret, PHOTO_SIZES[size_wanted][0,1].downcase, "jpg"]
  end


end
