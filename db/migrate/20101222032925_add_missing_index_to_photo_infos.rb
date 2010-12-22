class AddMissingIndexToPhotoInfos < ActiveRecord::Migration
  def self.up
    add_index :photo_infos, :photo_id
  end

  def self.down
    remove_index :photo_infos, :photo_id
  end
end
