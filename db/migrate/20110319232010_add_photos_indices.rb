class AddPhotosIndices < ActiveRecord::Migration
  def self.up
    add_index "photos", ["created_at"]
    add_index "photos", ["pos", "created_at"]
  end

  def self.down
  end
end
