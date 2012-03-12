class AddZzvIdToTrackedLinks < ActiveRecord::Migration
  def self.up
    add_column :tracked_links, :zzv_id, :string

  end

  def self.down
    remove_column :users, :zzv_id
  end
end
