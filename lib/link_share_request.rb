class LinkShareRequest < Struct.new(:share_id, :url_to_share)

  def perform
    @share = Share.find(share_id)
    bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key])
    url = bitly.shorten(url_to_share)
    @share.link_to_share = url.short_url
    @share.deliver
  end

  def on_permanent_failure
    photo.update_attributes(:state => 'error', :error_message => 'Failed to share the link')
  end

end