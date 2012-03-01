class TwitterIdentity < Identity
  include PrettyUrlHelper

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
      raise InvalidToken if @api.nil? || @api.client.nil? || !@api.client.authorized?
    end
    return @api
  end

  def post( link, message="" )
      self.twitter_api.client.update( message + ' ' + link)
  end

  def post_share( share )
     # we decided to have the @ZangZing and the link as part of the message
     # if user deletes -- that's just the way it goes...
     post('', share.message )
  end

  def post_like( like, message )
    post( bitly_url(like.url), message )
  end



  def post_streaming_album_update(batch)
    album = batch.album
    user = batch.user
    photos = batch.photos
    

    link = bitly_url(album_activities_pretty_url(album))

    message = "#{user.name} added #{photos.count} #{(photos.count > 1 ? 'photos':'photo')} to #{album.name} #{link} @ZangZing"

    self.post('', message)

  end
end