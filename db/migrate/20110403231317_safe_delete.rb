class SafeDelete < ActiveRecord::Migration
  def self.up
    add_column :photos, :deleted_at, :datetime
    add_column :albums, :deleted_at, :datetime

    add_index :photos, :deleted_at
    add_index :albums, :deleted_at
  end

  def self.down
    remove_column :photos, :deleted_at
    remove_column :albums, :deleted_at
  end
end
