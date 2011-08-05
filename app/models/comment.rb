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
      CommentActivity.create(:user => self.user, :subject => self.commentable.photo.album, :comment => self)
    end
  end
end