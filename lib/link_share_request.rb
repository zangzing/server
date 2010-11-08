class LinkShareRequest < Struct.new(:share_id, :url_to_share)

  def perform
    @share = Share.find(share_id)
    bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key])
    url = bitly.shorten(url_to_share)
    @share.link_to_share = url.short_url
    @share.deliver
  end

  def on_permanent_failure
    #TODO Report an error in a more effective way
    logger.error "Failed to share the link. ShareID=#{share_id}"
  end

end