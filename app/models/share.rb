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

  has_many :recipients, :dependent => :destroy
  accepts_nested_attributes_for :recipients,  :reject_if => proc { |attrs| attrs['service'] == "" }

  validates_presence_of :album_id, :user_id

  def self.factory(user, album, params)
    @share = MailShare.factory(user, params[:mail_share]) if params[:mail_share]
    @share = PostShare.factory(user, params[:post_share]) if params[:post_share]
    user.shares  << @share
    album.shares << @share
    return @share
  end


end
