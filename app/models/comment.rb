class Comment < ActiveRecord::Base

  attr_accessible :text

  belongs_to :commentable, :counter_cache => true
  belongs_to :user


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


  def share_to_facebook
    self.user.identity_for_facebook.
  end


  def share_to_twitter

  end

end
