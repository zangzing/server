# == Schema Information
# Schema version: 20100610185856
#
# Table name: contacts
#
#  id          :integer         not null, primary key
#  identity_id :integer
#  name        :string(255)
#  address     :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Contact < ActiveRecord::Base
end
