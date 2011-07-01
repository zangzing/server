#
#   Copyright 2011, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class ShareActivity < Activity
  attr_accessible :share
  validates_presence_of :share

  # The payload is the share id

  before_save :save_share_id

  def save_share_id
    self.payload = @share.id
  end

  def share
    @share ||= Share.find( self.payload )
  end

  def share=( s )
    if s.is_a?(Share)
      @share = s
    else
      raise new Exception("Argument must be a Share");
    end
  end

  def payload_valid?
    begin
      return true if share && share.subject        
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def display_for?( current_user )
    if share.subject.is_a?(Photo)
      return true if share.subject.album.public?
      return true if current_user && share.subject.album.viewer_in_group?( current_user.id )
    elsif share.subject.is_a?(Album)
      return true if share.subject.public?
      return true if current_user && share.subject.viewer_in_group?( current_user.id )
    elsif share.subject.is_a?(User)
      return true
    end
    false
  end
end

