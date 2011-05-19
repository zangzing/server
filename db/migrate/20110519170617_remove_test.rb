class RemoveTest < ActiveRecord::Migration
  def self.up
    drop_table :test_migrate1
  end

  def self.down
  end
end
