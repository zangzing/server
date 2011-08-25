class AddPhotoCounts < ActiveRecord::Migration
  def self.up
    add_column :albums, :photos_count, :int, :default => 0

    # set the current counts
    Album.reset_column_information
    Album.all.each do |album|
      Album.reset_counters album.id, :photos
    end
  end

  def self.down
    remove_column :albums, :photos_count
  end
end
