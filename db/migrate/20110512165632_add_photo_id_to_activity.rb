class AddPhotoIdToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :photo_id, :bigint
  end

  def self.down
    remove_column :activities, :photo_id

  end
end
