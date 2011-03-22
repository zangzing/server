# == Schema Information
# Schema version: 60
#
# Table name: activities
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  user_id    :integer
#  album_id   :integer
#  payload    :text
#  created_at :datetime
#  updated_at :datetime
#

#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Activity < ActiveRecord::Base
  attr_accessible :user

  belongs_to :user
  validates_presence_of :user_id

  default_scope :order => "updated_at DESC"
  
  ##
  ## ATTENTION: If you want helpers and forms treat all subtypes as Activities see
  ## the trick that we use for albums in Album.rb
  ##
  # All url, path and form helpers treat all subclasses as Activity
  def self.model_name
    name = "activity"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
      def human;    singularize; end # only for Rails 3
    end
    return name
  end
end