class AddEzPrintsUser < ActiveRecord::Migration
  def self.up
    User.reset_column_information
  end

  def self.down
  end
end
