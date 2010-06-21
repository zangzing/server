class AddAuthlogicToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :crypted_password, :string
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_column :users, :single_access_token, :string
    add_column :users, :perishable_token, :string, :default => "", :null => false


    remove_column :users, :salt
    remove_column :users, :encrypted_password

    add_column :users, :login_count, :integer
    add_column :users, :failed_login_count, :integer
    add_column :users, :last_request_at, :date
    add_column :users, :current_login_at, :date
    add_column :users, :last_login_at, :date
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string

    add_index :users, :perishable_token

  end

  def self.down
    remove_column :users, :crypted_password, :string
    remove_column :users, :password_salt, :string
    remove_column :users, :persistence_token, :string
    remove_column :users, :single_access_token, :string
    remove_column :users, :perishable_token, :string


    add_column :users, :salt, :string
    add_column :users, :encrypted_password, :string

    remove_column :users, :last_login_ip
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_at
    remove_column :users, :current_login_at
    remove_column :users, :last_request_at
    remove_column :users, :failed_login_count
    remove_column :users, :login_count
  end
end
