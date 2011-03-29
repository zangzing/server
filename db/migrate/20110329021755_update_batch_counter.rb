class UpdateBatchCounter < ActiveRecord::Migration
  def self.up
    # On migration, mark all albums as completed_batch_count 1 so they will show.
    # After this initial migration the true state will be indicated on future
    # albums.
    sql.execute("UPDATE albums SET completed_batch_count = 1;")
  end

  def self.down
  end
end
