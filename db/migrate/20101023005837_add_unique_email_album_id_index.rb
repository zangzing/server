class AddUniqueEmailAlbumIdIndex < ActiveRecord::Migration
  def self.up
    add_index :contributors, [:email, :album_id], :name => "email_album_unique_index", :unique => true
  end

  def self.down
    remove_index :contributors, :name => "email_album_unique_index"
  end
end
