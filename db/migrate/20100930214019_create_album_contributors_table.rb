class CreateAlbumContributorsTable < ActiveRecord::Migration
  def self.up
    create_table :contributors, :guid=>false,:force=>true do |t|
      t.references_with_guid  :album
      t.references_with_guid  :user, :null => true
      t.string                :name,  :null => true
      t.string                :email
      t.datetime              :last_contribution
      t.timestamps
    end
    add_index :contributors, :album_id
    add_index :contributors, :email
  end

  def self.down
    drop_table :contributors
  end
end
