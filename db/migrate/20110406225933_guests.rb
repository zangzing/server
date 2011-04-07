class Guests < ActiveRecord::Migration
  def self.up
     create_table :guests, :force => true do |t|
      t.string    :email,  :null => :false
      t.string    :source, :null => :false
      t.column    :user_id, :bigint
      t.string    :status, :default => 'Pending Signup'
      t.timestamps
     end
     add_index :guests, :email , :unique => true
  end

  def self.down
    drop_table :guests
  end
end
