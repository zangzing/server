# == Schema Information
# Schema version: 60
#
# Table name: oauth_tokens
#
#  id                    :integer         not null, primary key
#  user_id               :integer
#  agent_id              :string(255)
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
#

#
#   � 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AccessToken < OauthToken
  validates_presence_of :user
  before_create :set_authorized_at
  
  # Implement this to return a hash or array of the capabilities the access token has
  # This is particularly useful if you have implemented user defined permissions.
  # def capabilities
  #   {:invalidate=>"/oauth/invalidate",:capabilities=>"/oauth/capabilities"}
  # end

  def get_agent_token( agent_id, agent_version )
    return false unless authorized?
    AccessToken.transaction do
      agent = Agent.create(:user => user, :client_application => client_application, :agent_id => agent_id, :agent_version => agent_version)
      invalidate!
      agent
    end
  end

  protected
  
  def set_authorized_at
    self.authorized_at = Time.now
  end
end
