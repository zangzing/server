class ModifySessionsTable < ActiveRecord::Migration
  def self.up
    change_column :sessions, :session_id, :string, :null => false
  end

  def self.down
  end
end
