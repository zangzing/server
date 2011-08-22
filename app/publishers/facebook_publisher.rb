class FacebookPublisher < ActionMailer::Base
  include PrettyUrlHelper


  def self.test_mode=(b)
    @@test_mode = b
  end

  def self.test_mode
    @@test_mode ||= false
  end

  def self.test_posts=(posts)
    @@deliveries = posts
  end

  def self.test_posts
    @@deliveries ||= []
  end



  def photo_comment(comment_id)
    comment = Comment.find(comment_id)
    commentable = comment.commentable
    if commentable.subject_type == Commentable::SUBJECT_TYPE_PHOTO
      user = comment.user
      photo = Photo.find(comment.commentable.subject_id)
      FacebookPublisher.post_to_facebook(user, comment.text, photo.thumb_url, photo.caption, photo_pretty_url(photo))
    end
  end

  

private
  
  def self.post_to_facebook(user, message, picture, name, link, caption = nil, description = nil, actions = nil)
      caption ||= SystemSetting[:facebook_post_caption]
      description ||= SystemSetting[:facebook_post_description]
      actions || SystemSetting[:facebook_post_actions]

      params = {
          :message     => message,         #Displayed right under the user's name
          :picture     => picture,         #Displayed in the body of the post
          :name        => name,            #Displayed as a link to link
          :link        => link,            #The URL to where the name-link points to
          :caption     => caption,         #Displayed under the name
          :description => description,     #Displayed under the name/link/caption combo can be multiline
          :actions     => actions
      }

      if self.test_mode
        self.test_posts << params        
      else
        user.identity_for_facebook.facebook_graph.post("me/feed", params)
      end
  end



end