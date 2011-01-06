class AddUserIdAlbumIdIndexToShares < ActiveRecord::Migration
  def self.up
    add_index :shares, [:user_id, :album_id], :name => "userid_albumid_index"

  end

  def self.down
    remove_index :shares, :name => "userid_albumid_index"
  end
end
