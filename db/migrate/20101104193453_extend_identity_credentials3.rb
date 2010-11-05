class ExtendIdentityCredentials3 < ActiveRecord::Migration
  def self.up
    #Windows Live ID forces us to extend credentials field more
    change_column :identities, :credentials, :string, :limit => 2048
  end

  def self.down
    change_column :identities, :credentials, :string, :limit => 1024
  end
end
