class AddPiconToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :picon_file_name,    :string
    add_column :albums, :picon_content_type, :string
    add_column :albums, :picon_file_size,    :integer
    add_column :albums, :picon_path,         :string
    add_column :albums, :picon_bucket,       :string
    add_column :albums, :picon_updated_at,   :datetime
  end

  def self.down
    remove_column :albums, :picon_file_name
    remove_column :albums, :picon_content_type
    remove_column :albums, :picon_file_size
    remove_column :albums, :picon_path
    remove_column :albums, :picon_bucket
    remove_column :albums, :picon_updated_at
  end
end
