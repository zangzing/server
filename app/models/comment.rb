class Comment < ActiveRecord::Base

  attr_accessible :comment

  belongs_to :commentable, :counter_cache => true
  belongs_to :user

  def to_json
    super.to_json
  end

  def as_json
    hash = super.as_json

    user = self.user

    hash[:user] = {
        :first_name => user.first_name,
        :last_name => user.first_name,
        :username => user.username,
        :profile_photo_url => user.profile_photo_url
    }

    return hash
  end


end
