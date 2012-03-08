class IdentitiesAddKeys < ActiveRecord::Migration
  def self.up
    remove_index :identities, :column => :service_user_id
    add_index :identities, [:service_user_id, :identity_source], :unique => true
  end

  def self.down
  end
end
