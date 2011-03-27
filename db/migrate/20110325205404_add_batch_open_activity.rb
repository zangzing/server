class AddBatchOpenActivity < ActiveRecord::Migration
  def self.up
    add_column :upload_batches, :open_activity_at, :datetime, :default => Time.at(0)
    add_column :upload_batches, :lock_version, :integer, :default => 0

    add_index "upload_batches", ["open_activity_at", "state"]
  end

  def self.down
  end
end
