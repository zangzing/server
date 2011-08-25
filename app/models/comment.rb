class Comment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  attr_accessible :text

  belongs_to :commentable, :counter_cache => true
  belongs_to :user


  after_create  :create_comment_activity

  default_scope  :order => "created_at DESC"


  def as_json
    json = self.attributes

    json['when'] = time_ago_in_words(self.created_at)

    json['user'] = {
        'name' => self.user.name,
        'username' => self.user.username,
        'profile_photo_url' => self.user.profile_photo_url
    }

    return json

  end


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


      # users who like photo
      Like.find_by_photo_id(photo.id).each do |like|
        users_to_notify << like.user
      end


      # users who like album
      Like.find_by_album_id(photo.album.id).each do |like|
        users_to_notify << like.user
      end

      # de-dup and remove current user
      users_to_notify.uniq!

      # remove current user
      users_to_notify.delete(self.user)

      users_to_notify.each do |user_to_notify|
        ZZ::Async::Email.enqueue(:photo_comment, self.user.id, user_to_notify.id, self.id)
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
      CommentActivity.create(:user => self.user, :subject => self.commentable.subject.album, :comment => self)
    end
  end
end
