class AddUploadBatchIndices < ActiveRecord::Migration
  def self.up
    add_index "upload_batches", ["created_at"]
    add_index "upload_batches", ["updated_at"]
    add_index "upload_batches", ["state"]
  end

  def self.down
  end
end
