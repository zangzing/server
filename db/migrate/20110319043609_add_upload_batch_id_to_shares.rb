class AddUploadBatchIdToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :upload_batch_id, :bigint
  end

  def self.down
    remove_column :shares, :upload_batch_id
  end
end
