class Comment < ActiveRecord::Base

  attr_accessible :text

  belongs_to :commentable, :counter_cache => true
  belongs_to :user


end
