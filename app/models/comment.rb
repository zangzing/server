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
      album = photo.album

      # this will contain user ids and/or email addresses
      users_to_notify = []

      # photo owner
      users_to_notify << photo.user.id

      # album owner
      users_to_notify << album.user.id

      # others who have commented
      self.commentable.comments.each do |comment|
        users_to_notify << comment.user.id
      end

      # users who like photo
      Like.find_by_photo_id(photo.id).each do |like|
        users_to_notify << like.user.id
      end


      # users who like album
      Like.find_by_album_id(photo.album.id).each do |like|
        users_to_notify << like.user.id
      end

      # all viewers and contributors of album
      if album.stream_to_email?
        viewers ||= album.viewers(false)

        # viewers comes back as strings of ids or emails
        viewers.each do |viewer|
          # if viewer doesn't parse, this will return 0
          viewer_id = viewer.to_i
          if viewer_id == 0
            users_to_notify << viewer
          else
            users_to_notify << viewer_id
          end

        end
      end

      # de-dupe and remove current user
      users_to_notify.uniq!

      # remove current user
      users_to_notify.delete(self.user.id)

      # if password album, remove users who are not in ACL
      if album.private?
        viewers ||= album.viewers(false)
        users_to_notify.reject! { |userid_or_email|
          !viewers.include?(userid_or_email.to_s)
        }
      end

      users_to_notify.each do |user_to_notify|
        ZZ::Async::Email.enqueue(:photo_comment, self.user.id, user_to_notify, self.id)
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
