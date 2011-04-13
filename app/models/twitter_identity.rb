class TwitterIdentity < Identity
  require 'connector_exceptions'

  DEFAULT_SHARE_MESSAGE = "Sharing some @ZangZing photos"

  def twitter_api
    unless @api
      raise InvalidToken unless self.credentials
      begin
        @api = TwitterConnector.new(self.credentials)
      rescue => exception
        raise InvalidToken if exception.kind_of?(Twitter::Unauthorized)
        raise HttpCallFail if exception.kind_of?(SocketError)
      end
      raise InvalidToken unless twitter_api.client.authorized?
    end
    return @api
  end

  def post( link, message="" )
      self.twitter_api.client.update( message + ' ' + link)
  end

  def post_share( share )
     bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key]).shorten( share.subject_url )
     post( bitly.short_url,
           (share.message && share.message.length > 0 ? share.message+" @ZangZing" : DEFAULT_SHARE_MESSAGE) )
  end

  def post_like( like, message )
    bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key]).shorten( like.url )
    post( bitly.short_url, message )
  end

end