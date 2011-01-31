class ModifyForPhotoProcessing < ActiveRecord::Migration
  def self.up
    remove_column :albums, :last_upload_started_at
    remove_column :albums, :picon_file_name

    remove_column :photos, :image_file_name
    remove_column :photos, :local_image_file_name
    remove_column :photos, :local_image_content_type
    remove_column :photos, :local_image_file_size
    remove_column :photos, :local_image_updated_at
    remove_column :photos, :local_image_path
    remove_column :photos, :metadata

    add_column :photos, :rotate_to, :integer, :default => 0
    add_column :photos, :generate_queued_at, :datetime, :default => Time.at(0), :null => false
    rename_column :photos, :length, :height
  end

  def self.down
    remove_column :photos, :rotate_to
    remove_column :photos, :generate_queued_at
    rename_column :photos, :height, :length
  end
end
