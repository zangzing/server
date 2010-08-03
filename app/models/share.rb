# == Schema Information
# Schema version: 20100707184116
#
# Table name: shares
#
#  id               :integer         not null, primary key
#  album_id         :integer
#  user_id          :integer
#  email_to         :string(255)
#  email_subject    :string(255)
#  email_message    :text
#  twitter_message  :string(255)
#  facebook_message :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :album
  validates_presence_of :album_id, :user_id
end
