class AddPhotosSource < ActiveRecord::Migration
  def self.up
    add_column :photos, :source, :string
  end

  def self.down
    remove_column :photos, :source
  end
end
