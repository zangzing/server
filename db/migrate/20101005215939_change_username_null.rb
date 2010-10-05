class ChangeUsernameNull < ActiveRecord::Migration
  def self.up
    change_column :users, :username,  :string,  :null=>true
  end

  def self.down
    change_column :users, :username,  :string,  :null=>false
  end
end
