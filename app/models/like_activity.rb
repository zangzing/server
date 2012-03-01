#
#   Copyright 2011, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class LikeActivity < Activity
  attr_accessible :like
  validates_presence_of :like

  # The payload is the like id
  before_save :save_like_id

  def save_like_id
    self.payload = @like.id
  end

  def like
    @like ||= Like.find( self.payload )
  end

  def like=( l )
    if l.is_a?(Like)
      @like = l
    else
      raise new Exception("Argument must be a Like");
    end
  end

  def payload_valid?
    begin
      return true if like  && like.user && like.subject
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def display_for?( current_user, view )
    if like.subject.is_a?(Photo)
      return true if like.subject.album.public?
      return true if view == ALBUM_VIEW && like.subject.album.hidden?
      return true if current_user && like.subject.album.viewer?( current_user.id )
    elsif like.subject.is_a?(Album)
      return true if like.subject.public?
      return true if view == ALBUM_VIEW && like.subject.hidden?
      return true if current_user && like.subject.viewer?( current_user.id )
    elsif like.subject.is_a?(User)
      return true
    end
    false
  end
end
