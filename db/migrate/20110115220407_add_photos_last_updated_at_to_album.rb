class AddPhotosLastUpdatedAtToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :photos_last_updated_at, :datetime, :default => Time.now, :null => false
  end

  def self.down
    remove_column :albums, :photos_last_updated_at
  end
end
