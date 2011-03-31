class CreateUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_preferences, :force => true do |t|
           t.column                 :user_id, :bigint, :null => false
           t.boolean                :tweet_likes,      :default => false
           t.boolean                :facebook_likes,   :default => false
           t.boolean                :asktopost_likes,  :default => true
       end
       add_index :user_preferences, :user_id
  end

  def self.down
     drop_table :user_preferences
  end
end
