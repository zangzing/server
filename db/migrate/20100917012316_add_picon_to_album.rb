class AddPiconToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :picon_id, :guid, :null => true
  end

  def self.down
    remove_column :albums, :picon_id
  end
end
