class AddAgentIdToOauthToken < ActiveRecord::Migration
  def self.up    
    add_column :oauth_tokens, :agent_id, :string
  end

  def self.down
    remove_column :oauth_tokens, :agent_id
  end
end
