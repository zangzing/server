class UserPersistenceIndex < ActiveRecord::Migration
  def self.up
    add_index "users", ["persistence_token"]
  end

  def self.down
  end
end
