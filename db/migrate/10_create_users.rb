class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
       t.string   :email,                 :null => false
       t.string   :role,                  :null => false, :default => "user"
       t.string   :username,              :null => false
       t.string   :first_name,            :null => false
       t.string   :last_name
       t.string   :style,                 :null => false, :default => "white"
       t.string   :suspended,             :null => false, :default => false

       t.string   :crypted_passwor\d,      :null => false
       t.string   :password_salt,         :null => false
       t.string   :persistence_token,     :null => false
       t.string   :single_access_token,   :null => false
       t.string   :perishable_token,      :null => false

       t.integer  :failed_login_count,    :null => false, :default => 0
       t.date     :current_login_at
       t.date     :last_login_at
       t.string   :current_login_ip
       t.string   :last_login_ip
       t.timestamps
     end

     add_index :users, :email, :unique => true
     add_index :users, :username, :unique => true
     add_index :users, :perishable_token
  end

  def self.down
    drop_table :users
  end
end
