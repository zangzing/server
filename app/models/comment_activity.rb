#
#   Copyright 2011, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class CommentActivity < Activity
  attr_accessible :comment
  validates_presence_of :comment

  # The payload is the like id
  before_save :save_comment_id

  def save_comment_id
    self.payload = self.comment.id
  end

  def comment
    @comment ||= Comment.find(self.payload)
  end

  def comment=(comment)
    if comment.is_a?(Comment)
      @comment = comment
    else
      raise new Exception("must be a Comment");
    end
  end

  def payload_valid?
    begin
      return true if comment && comment.user && comment.subject
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def display_for?(current_user, view)
    if comment.subject.is_a?(Photo)

      # show comment activity for public albums
      return true if comment.subject.album.public?


      # show comment on album view for hidden albums
      return true if view == ALBUM_VIEW && comment.subject.album.hidden?

      # show comment if current user is in the album's group
      return true if current_user && comment.subject.album.viewer_in_group?(current_user.id)
    end
    return false
  end
end
