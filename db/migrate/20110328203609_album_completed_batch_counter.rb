class AlbumCompletedBatchCounter < ActiveRecord::Migration
  def self.up
    add_column :albums, :completed_batch_count, :integer, :default => 0

    # on migration, mark all albums as completed_batch_count 1 so they will show
    # after this initial migration the true state will be indicated on future
    # albums
    sql.execute("UPDATE albums SET completed_batch_count = 1;")

  end

  def self.down
  end
end
