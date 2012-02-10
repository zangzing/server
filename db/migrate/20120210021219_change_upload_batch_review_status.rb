class ChangeUploadBatchReviewStatus < ActiveRecord::Migration
  def self.up
    change_column :upload_batches, :review_status, :string, :default => 'unreviewed', :limit => 20
    UploadBatch.where(:review_status => nil).update_all(:review_status => 'unreviewed')
  end

  def self.down
    change_column :upload_batches, :review_status, :string, :limit => 20
  end
end
