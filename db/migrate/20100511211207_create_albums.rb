class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.integer :user_id

      t.timestamps
    end
    add_index :albums, :user_id
  end

  def self.down
    drop_table :albums
  end
end
