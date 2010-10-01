# == Schema Information
# Schema version: 60
#
# Table name: shares
#
#  id         :integer         not null, primary key
#  album_id   :integer
#  user_id    :integer
#  type       :string(255)
#  subject    :string(255)
#  message    :text
#  created_at :datetime
#  updated_at :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#
class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :album

  attr_accessor :link_to_share

  has_many :recipients, :dependent => :destroy
  validates_presence_of :album_id, :user_id

  def self.factory(user, album, params)
    share = EmailShare.factory(user, params[:email_share]) if params[:email_share]
    share = PostShare.factory(user, params[:post_share]) if params[:post_share]
    user.shares  << share
    album.shares << share
    return share
  end

  def deliver_later
     #Delayed::IoBoundJob.enqueue Delayed::PerformableMethod.new(self, :deliver, [])
     Delayed::IoBoundJob.enqueue LinkShareRequest.new(self.id, self.link_to_share)
  end
   
end
