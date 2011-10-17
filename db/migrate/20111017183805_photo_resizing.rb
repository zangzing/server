class PhotoResizing < ActiveRecord::Migration
  def self.up
    add_column :photos, :size_version, :integer
    add_column :photos, :original_suffix, 'integer unsigned'

    add_index :photos, :size_version
  end

  def self.down
    remove_column :photos, :size_version
    remove_column :photos, :original_suffix
  end
end
