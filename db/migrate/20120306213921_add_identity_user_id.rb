class AddIdentityUserId < ActiveRecord::Migration
  def self.up
    add_column :identities, :service_user_id, :string
    add_index :identities, [:service_user_id]
  end

  def self.down
    remove_column :identities, :service_user_id
  end
end
