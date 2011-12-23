class ChangeLogEntriesDetailsCol < ActiveRecord::Migration
  def self.up
    change_column :log_entries, :details, :mediumtext
  end

  def self.down
    change_column :log_entries, :details, :text
  end
end
