class AddReviewStatusToUploadBatches < ActiveRecord::Migration
  def self.up
    add_column :upload_batches, :review_status, :string, :limit => 20
  end

  def self.down
    remove_column :upload_batches, :review_status
  end
end
