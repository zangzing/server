class AddCustomOrderToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :custom_order, :boolean, :default=> false
  end

  def self.down
    remove_column :albums, :custom_order
  end
end
