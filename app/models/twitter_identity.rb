class TwitterIdentity < Identity
  include PrettyUrlHelper

  require 'connector_exceptions'

  DEFAULT_SHARE_MESSAGE = "Sharing some @ZangZing photos"

  def twitter_api
    unless @api
      raise InvalidToken unless self.credentials
      @api = TwitterConnector.new(self.credentials)
      raise InvalidToken unless @api.client && @api.client.authorized?
    end
    return @api
  end

  # verify that the token is actually valid by checking
  # with the remote service
  def verify_credentials
    return false unless has_credentials? # make sure we actually have an api token set
    begin
      if defined?(@api)
        valid = twitter_api.client.authorized?
      else
        twitter_api   # just fetching it the first time does an authorized check
        valid = true
      end
    rescue InvalidToken => ex
      valid = false
    rescue Exception => ex
      valid = true    # non twitter validation error assume ok since could be network issue
    end
    valid
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