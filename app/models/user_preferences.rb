require 'digest/sha1'

class UserPreferences < ActiveRecord::Base
  attr_accessible :email, :user_id,
                  :ask_to_post_likes,    :facebook_likes,  :tweet_likes,
                  :want_marketing_email, :want_news_email, :want_social_email, :want_status_email, :want_invites_email

  belongs_to  :user

  validates_presence_of :email
    

  NEVER       = 0
  IMMEDIATELY = 1
  DAILY       = 2
  WEEKLY      = 3

  UNSUBSCRIBE_TOKEN_SECRET = "This-is-a-secret-number-6872296"

  def email=(address)
    write_attribute(:email, address )
    write_attribute(:unsubscribe_token, Digest::SHA1.hexdigest( UNSUBSCRIBE_TOKEN_SECRET+address ))
  end

end