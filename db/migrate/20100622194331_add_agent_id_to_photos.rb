class AddAgentIdToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :agent_id, :string
  end

  def self.down
    remove_column :photos, :agent_id
  end
end
