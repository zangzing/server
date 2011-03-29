class AlbumCompletedBatchCounter < ActiveRecord::Migration
  def self.up
    add_column :albums, :completed_batch_count, :integer, :default => 0
  end

  def self.down
    remove_column :albums, :completed_batch_count
  end
end
