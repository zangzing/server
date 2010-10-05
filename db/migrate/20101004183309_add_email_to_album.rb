class AddEmailToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :email, :string
  end

  def self.down
    remove_column :albums, :email
  end
end
