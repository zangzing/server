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
  validates_presence_of :album_id, :user_id
  
  def self.factory(user, album, album_url, params)
    share = EmailShare.factory(user, params[:email_share]) if params[:email_share]
    share = PostShare.factory(user, params[:post_share]) if params[:post_share]
    share.album_url = album_url
    user.shares  << share
    album.shares << share
    return share
  end

  def self.send_album_shares( user_id, album_id )
    if album_id.nil? || user_id.nil?
      raise Exception.new("Album Id and User Id must be valid Ids (not nil)")
    end

    shares = Share.find_all_by_user_id_and_album_id(user_id, album_id)
    shares.each { |share|  ZZ::Async::AlbumShare.enqueue( share.id ) } unless shares.nil?
  end

  protected
  def deliver
      if self.sent_at.nil?
        self.sent_at = Time.now
        bitly = Bitly.new(BITLY_API_KEYS[:username], BITLY_API_KEYS[:api_key])
        url = bitly.shorten( self.album_url )
        self.bitly = url.short_url
        return self.save
      end
      return false  
  end

end
