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

  def display_for?( current_user, view )
    if share.subject.is_a?(Photo)
      return true if share.subject.album.public?
      return true if view == ALBUM_VIEW && share.subject.album.hidden?
      return true if current_user && share.subject.album.viewer?( current_user.id )
    elsif share.subject.is_a?(Album)
      return true if share.subject.public?
      return true if view == ALBUM_VIEW && share.subject.hidden?
      return true if current_user && share.subject.viewer?( current_user.id )
    elsif share.subject.is_a?(User)
      return true
    end
    false
  end
end

