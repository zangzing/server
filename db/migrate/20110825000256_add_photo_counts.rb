class AddPhotoCounts < ActiveRecord::Migration
  def self.up
    add_column :albums, :photos_count, :int, :default => 0
  end

  def self.down
    remove_column :albums, :photos_count
  end
end
