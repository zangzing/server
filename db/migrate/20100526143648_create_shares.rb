class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.integer :album_id
      t.integer :user_id
      t.string :email_to
      t.string :email_subject
      t.text :email_message
      t.string :twitter_message
      t.string :facebook_message

      t.timestamps
    end

    add_index :shares, :user_id
    add_index :shares, :album_id


  end

  def self.down
    drop_table :shares
  end
end
