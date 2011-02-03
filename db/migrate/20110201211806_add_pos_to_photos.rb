class AddPosToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :pos, :double
  end

  def self.down
    remove_column :photos, :pos
  end
end
