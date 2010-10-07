class TwitterIdentity < Identity
  require 'connector_exceptions'

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

end