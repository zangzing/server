class AddActiveToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default => false, :null => false
    add_column :users, :approved,  :boolean, :default => true, :null => false
    remove_column :users, :suspended
  end

  def self.down
    remove_column :users, :active
    remove_column :users, :approved
    add_column :users, :suspended, :boolean, :default => false, :null => false
  end
end
