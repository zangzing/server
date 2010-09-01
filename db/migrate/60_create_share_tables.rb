class CreateShareTables < ActiveRecord::Migration
  def self.up
    create_table :shares, :guid=>false,:force=>true do |t|
      t.references_with_guid  :album
      t.references_with_guid  :user
      t.string   :type
      t.string   :subject
      t.text     :message
      t.datetime :sent_at
      t.timestamps
    end
    add_index :shares, :user_id
    add_index :shares, :album_id
  
    create_table :recipients, :guid=>false,:force=>true do |t|
      t.integer :share_id
      t.string  :service
      t.string  :name
      t.string  :address
      t.timestamps
    end
    add_index :recipients, :share_id
  end
  
  def self.down
    drop_table :recipients
    drop_table :shares
  end
end
