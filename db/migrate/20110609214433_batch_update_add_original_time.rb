class BatchUpdateAddOriginalTime < ActiveRecord::Migration
  def self.up
    add_column :upload_batches, :original_batch_created_at, :datetime, :default => Time.at(0)
  end

  def self.down
    remove_column :upload_batches, :original_batch_created_at
  end
end
