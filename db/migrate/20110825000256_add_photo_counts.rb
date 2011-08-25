class AddPhotoCounts < ActiveRecord::Migration
  def self.up
    add_column :albums, :photos_count, :int, :default => 0

    # Only run the update for the counts on non production
    # machines.  Production needs downtime so we separated
    # the update into the Album model which can be
    # called manually via the rails console.
    if ENV["RAILS_ENV"] != 'photos_production'
      Album.update_all_photo_counts
    end
  end

  def self.down
    remove_column :albums, :photos_count
  end
end
