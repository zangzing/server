class AddPosToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :pos, :float, :default => 0.0
  end

  def self.down
    remove_column :photos, :pos
  end
end
