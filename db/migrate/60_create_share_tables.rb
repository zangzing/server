class CreateShareTables < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.integer  :album_id
      t.integer  :user_id
      t.string   :type
      t.string   :subject
      t.text     :message
      t.timedate :sent_at
      t.timestamps
    end
    add_index :shares, :user_id
    add_index :shares, :album_id
  
    create_table :recipients do |t|
      t.integer :share_id
      t.string  :type
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
