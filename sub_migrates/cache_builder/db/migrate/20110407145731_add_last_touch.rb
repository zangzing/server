class AddLastTouch < ActiveRecord::Migration
  def self.up
    add_column :c_versions, :user_last_touch_at, :integer

    add_index :c_versions, :user_last_touch_at
  end

  def self.down
    remove_column :c_versions, :user_last_touch_at
  end
end
