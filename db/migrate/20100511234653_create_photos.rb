class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :album_id
      
      t.timestamps
    end
    add_index :photos, :album_id
  end

  def self.down
    drop_table :photos
  end
end
