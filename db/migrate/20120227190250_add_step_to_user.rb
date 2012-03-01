class AddStepToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :completed_step, :integer
    add_index :users, [:completed_step]
  end

  def self.down
    remove_column :users, :completed_step
  end
end
