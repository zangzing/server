# == Schema Information
# Schema version: 20100804213110
#
# Table name: oauth_tokens
#
#  id                    :integer         not null, primary key
#  user_id               :integer
#  type                  :string(20)
#  client_application_id :integer
#  token                 :string(20)
#  secret                :string(40)
#  callback_url          :string(255)
#  verifier              :string(20)
#  authorized_at         :datetime
#  invalidated_at        :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  agent_id              :string(255)
#

class Agent < AccessToken
  validates_presence_of :agent_id


end
