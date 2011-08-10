class TwitterPublisher < ActionMailer::Base
  include PrettyUrlHelper



  def photo_comment(comment_id)
    comment = Comment.find(comment_id)
    commentable = comment.commentable
    if commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      user = comment.user
      photo = Photo.find(comment.commentable.subject_id)
      url = bitly_url(photo_pretty_url(photo))

      TwitterPublisher.post_link_to_twitter(user, comment.text, url)
    end
  end

  


  def self.post_message_to_twitter(user, message)
    user.identity_for_twitter.twitter_api.client.update(message)
  end

  def self.post_link_to_twitter(user, message, url)
    if message.size + url.size > 140
      message = message[0,140 - (url.length + 4)]
      message = "#{message}... #{url}"
    else
      message = "#{message} #{url}"
    end

    self.post_message_to_twitter(user, message)
  end



end