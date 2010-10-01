class ExtendCredentialsFieldForIdentities < ActiveRecord::Migration
  def self.up
    change_column :identities, :credentials, :string, :limit => 800
  end

  def self.down
    change_column :identities, :credentials, :string, :limit => 400
  end
end
