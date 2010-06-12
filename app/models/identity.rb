# == Schema Information
# Schema version: 20100610185856
#
# Table name: identities
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  name                 :string(255)
#  credentials          :string(255)
#  last_contact_refresh :datetime
#  identity_source      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class Identity < ActiveRecord::Base

  has_many :contacts, :dependent => :destroy
  belongs_to :user

  
  def self.new_for_gmail
    identity = self.new
    identity.identity_source="gmail"
  end

end
