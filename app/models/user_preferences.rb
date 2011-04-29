class UserPreferences < ActiveRecord::Base
  attr_accessible :user_id, :ask_to_post_likes,    :facebook_likes,  :tweet_likes
  belongs_to  :user
end