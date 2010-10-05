class AddAutomaticToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :automatic, :boolean, :default => false
  end

  def self.down
    remove_column :users, :automatic
  end
end
