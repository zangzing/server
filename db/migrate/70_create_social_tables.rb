class CreateSocialTables < ActiveRecord::Migration
  def self.up

    create_table :follows do |t|
      t.integer  :follower_id
      t.integer  :followee_id
      t.boolean  :blocked, :default => false
      t.timestamps
    end
    add_index :follows, :follower_id
    add_index :follows, :followee_id

    create_table :activities do |t|
      t.string  :type
      t.integer :user_id
      t.integer :album_id
      t.text    :payload
      t.timestamps
    end  
    add_index :activities, :user_id
    add_index :activities, :album_id

  end
 
  
  def self.down
    drop_table :activities
    drop_table :followers
  end
end
