class AddCrc32ToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :crc32, 'integer unsigned'
  end

  def self.down
    remove_column :photos, :crc32
  end
end
