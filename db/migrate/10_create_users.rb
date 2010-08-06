class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
       t.string   :email
       t.string   :role
       t.string   :user_name
       t.string   :first_name
       t.string   :last_name
       t.string   :style,               :default => "white"
       
       t.integer  :login_count
       t.date     :last_login_at
       t.string   :last_login_ip
       t.date     :current_login_at     
       t.string   :current_login_ip
       t.integer  :failed_login_count
       t.date     :last_request_at
       
       t.string   :persistence_token       
       t.string   :single_access_token
       t.string   :perishable_token,    :default => "",      :null => false
       t.string   :remember_token
       t.string   :crypted_password
       t.string   :password_salt

       t.string   :suspended,   :default => false
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
