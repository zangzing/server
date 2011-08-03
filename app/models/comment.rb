class Comment < ActiveRecord::Base

  attr_accessible :text

  belongs_to :commentable, :counter_cache => true
  belongs_to :user


  after_commit  :create_comment_activity, :on => :create


  def send_notification_emails
    subject = self.commentable.subject

    if subject.is_a?(Photo)
      photo = subject

      users_to_notify = []

      # photo owner
      users_to_notify << photo.user

      # album owner
      users_to_notify << photo.album.user

      # others who have commented
      self.commentable.comments.each do |comment|
        users_to_notify << comment.user
      end

      # de-dup and remove current user
      users_to_notify.uniq!

      # remove current user
      users_to_notify.delete(self.user)

      users_to_notify.each do |user_to_notify|
        ZZ::Async::Email.enqueue(:comment_added_to_photo, self.user.id, user_to_notify.id, self.id)
      end

    end
  end


  def post_to_facebook
    ZZ::Async::Facebook.enqueue(:photo_comment, self.id)
  end

  def post_to_twitter
    ZZ::Async::Twitter.enqueue(:photo_comment, self.id)
  end

protected
  def create_comment_activity
    if self.commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      photo = self.commentable.photo

      # this makes the comment show up on the photo's album's activity view
      CommentActivity.create(:user => self.user, :subject => photo.album, :comment => self)

      # this makes the comment show up on the commenter's activity view
      unless (self.user.id == photo.user.id)
        LikeActivity.create( :user => photo.album.owner, :subject => photo.album.owner, :comment => self);
      end




    end



    # Like activities are reciprocal:
    # - One activity is created for the subject so that it appears on the subject's activity list.
    # - Another is created for the subject_owner so that it appears in the subject owner's activities list.
    # Both activities point to the same like but we avoid having to do a triple join.
    # Albums/Photos fetch their activity list using the subject_id field
    # Users fetch their activity list by looking at the user_id field
    LikeActivity.create( :user => self.user, :subject => @activity_subject, :like => self )
    unless( self.user.id == @subject_owner.id )
      # do not create a reciprocal like activity for self likes.
      LikeActivity.create( :user => @subject_owner, :subject => @subject_owner, :like => self);
    end
  end



end
