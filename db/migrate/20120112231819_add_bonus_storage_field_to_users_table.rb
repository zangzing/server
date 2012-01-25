class AddBonusStorageFieldToUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :bonus_storage, :integer, :default=>0
  end

  def self.down
    remove_column :users, :bonus_storage
  end
end
