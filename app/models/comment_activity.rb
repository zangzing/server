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
      raise "must be a Comment"
    end
  end

  def payload_valid?
    begin
      return true if comment && comment.user && comment.commentable.subject
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def display_for?(current_user, view)
    subject = comment.commentable.subject

    if subject.is_a?(Photo)
      case view
        when ALBUM_VIEW
          return true

        when USER_VIEW
          # always show if comment was on public album
          return true if subject.album.public?

          # show for hidden and passord albums if current_user is member of album's group
          return true if current_user && subject.album.viewer?(current_user.id)
      end

      return false
    end
  end
end
