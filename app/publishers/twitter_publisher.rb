class TwitterPublisher < ActionMailer::Base
  include PrettyUrlHelper



  def photo_comment(comment_id)
    comment = Comment.find(comment_id)
    commentable = comment.commentable
    if commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      user = comment.user
      photo = Photo.find(comment.commentable.subject_id)
      url = bitly_url(photo_pretty_url(photo))

      message = "#{comment.text} #{url}"

      TwitterPublisher.post_to_twitter(user, message)
    end
  end

  

private
  
  def self.post_to_twitter(user, message)
    user.identity_for_titter.twitter_api.client.update(message)
  end



end