class AddCustomOrderOffsetToUploadBatches < ActiveRecord::Migration
  def self.up
    add_column :upload_batches, :custom_order_offset, :double, :default => 0.0
  end

  def self.down
    remove_column :upload_batches, :custom_order_offset
  end
end
