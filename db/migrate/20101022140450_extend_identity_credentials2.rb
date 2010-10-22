class ExtendIdentityCredentials2 < ActiveRecord::Migration
  def self.up
    #Yahoo's token is ~820 chars length now
    change_column :identities, :credentials, :string, :limit => 1024
  end

  def self.down
    change_column :identities, :credentials, :string, :limit => 800
  end
end
