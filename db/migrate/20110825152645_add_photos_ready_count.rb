class AddPhotosReadyCount < ActiveRecord::Migration
  def self.up
    add_column :albums, :photos_ready_count, :int, :default => 0

    # Only run the update for the counts on non production
    # machines.  Production needs downtime so we separated
    # the update into the Album model which can be
    # called manually via the rails console.
    if ENV["RAILS_ENV"] != 'photos_production'
      Album.reset_column_information
      Album.update_all_photo_counters
    end
  end

  def self.down
    remove_column :albums, :photos_ready_count
  end
end
