class AddAgentVersionToToken < ActiveRecord::Migration
  def self.up
    add_column    :oauth_tokens, :agent_version, :string
  end

  def self.down
    remove_column :oauth_tokens, :agent_version
  end
end
