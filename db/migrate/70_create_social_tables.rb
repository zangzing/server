class CreateSocialTables < ActiveRecord::Migration
  def self.up

    create_table :follows,:guid => false,:force => true do |t|
      t.references_with_guid  :follower
      t.references_with_guid  :followee
      t.boolean  :blocked, :default => false
      t.timestamps
    end
    add_index :follows, :follower_id
    add_index :follows, :followee_id

    create_table :activities, :guid => false, :force => true do |t|
      t.string  :type
      t.references_with_guid :user
      t.references_with_guid :album
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
