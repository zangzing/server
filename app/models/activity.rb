#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Activity < ActiveRecord::Base

  attr_accessible :user, :subject, :subject_id

  belongs_to :user
  validates_presence_of :user_id

  belongs_to :subject, :polymorphic => true  #the subject can be user,album or photo
  validates_presence_of :subject_id

  default_scope  :order => "created_at DESC"
  
  ##
  ## ATTENTION: If you want helpers and forms treat all subtypes as Activities see
  ## the trick that we use for albums in Album.rb
  ##
  # All url, path and form helpers treat all subclasses as Activity
  def self.model_name
    name = "activity/base"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
      def human;    singularize; end # only for Rails 3
    end
    return name
  end


  def payload_valid?
    raise NotImplementedError.new("Activity sub-classes must implement a payload_valid? method to verify that their subject still exists")
  end

end