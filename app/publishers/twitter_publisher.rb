class TwitterPublisher < ActionMailer::Base
  include PrettyUrlHelper



  def photo_comment(comment_id)
    comment = Comment.find(comment_id)
    commentable = comment.commentable
    if commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      user = comment.user
      photo = Photo.find(comment.commentable.subject_id)
      url = bitly_url(photo_pretty_url(photo))

      TwitterPublisher.post_link_to_twitter(user, message, url)
    end
  end

  


  def self.post_message_to_twitter(user, message)
    user.identity_for_titter.twitter_api.client.update(message)
  end

  def self.post_link_to_twitter(user, message, url)
    message = message[0,140 - (url.length + 1)]
    message = "#{message} #{url}"
    self.post_message_to_twitter(user, message)
  end



end