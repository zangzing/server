class AddLocalImageToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :local_image_file_name, :string
    add_column :photos, :local_image_content_type, :string
    add_column :photos, :local_image_file_size, :integer
    add_column :photos, :local_image_updated_at, :datetime
  end

  def self.down
    remove_column :photos, :local_image_updated_at
    remove_column :photos, :local_image_file_size
    remove_column :photos, :local_image_content_type
    remove_column :photos, :local_image_file_name
  end
end
