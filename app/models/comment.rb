class Comment < ActiveRecord::Base

  attr_accessible :comment

  belongs_to :commentable, :counter_cache => true
  belongs_to :user


end
