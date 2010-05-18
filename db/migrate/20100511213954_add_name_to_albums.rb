class AddNameToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :name, :string
  end

  def self.down
    remove_column :albums, :name
  end
end
