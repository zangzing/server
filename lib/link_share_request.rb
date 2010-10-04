class LinkShareRequest < Struct.new(:share_id, :url_to_share)

  def perform
    @share = Share.find(share_id)
    @share.link_to_share = url_to_share
    @share.deliver
  end

  def on_permanent_failure
    photo.update_attributes(:state => 'error', :error_message => 'Failed to share the link')
  end

end