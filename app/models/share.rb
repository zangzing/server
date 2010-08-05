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
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :album

  has_many :recipients, :dependent => :destroy

  validates_presence_of :album_id, :user_id
end
