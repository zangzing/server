# == Schema Information
# Schema version: 60
#
# Table name: recipients
#
#  id         :integer         not null, primary key
#  share_id   :integer
#  type       :string(255)
#  name       :string(255)
#  address    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Recipient < ActiveRecord::Base
  belongs_to :share
  
  validates_presence_of :share_id
end
