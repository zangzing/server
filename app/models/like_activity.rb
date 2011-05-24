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
      return true if like
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

end
