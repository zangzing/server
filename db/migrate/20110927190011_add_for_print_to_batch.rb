class AddForPrintToBatch < ActiveRecord::Migration
  def self.up
    add_column    :upload_batches, :for_print, :boolean, :default => false
  end

  def self.down
    remove_column :upload_batches, :for_print
  end
end
