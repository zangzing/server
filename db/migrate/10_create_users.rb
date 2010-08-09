class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
       t.string   :email,                 :null => false
       t.string   :role,                  :null => false
       t.string   :user_name
       t.string   :first_name,            :null => false
       t.string   :last_name
       t.string   :style,                 :default => "white"
       t.string   :suspended,             :default => false

       t.string   :crypted_password,      :null => false
       t.string   :password_salt,         :null => false
       t.string   :persistence_token,     :null => false
       t.string   :single_access_token,   :null => false
       t.string   :perishable_token,      :null => false

       #t.integer  :login_count,           :null => false, :default => 0
       t.integer  :failed_login_count,    :null => false, :default => 0
       #t.date     :last_request_at
       t.date     :current_login_at
       t.date     :last_login_at
       t.string   :current_login_ip
       t.string   :last_login_ip
       


       t.timestamps
     end

     add_index :users, :email, :unique => true
     add_index :users, :perishable_token
     add_index :users, :remember_token
  end

  def self.down
    drop_table :users
  end
end
