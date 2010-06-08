class AddStateToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :state, :string,  :default => 'new'
  end

  def self.down
    remove_column :photos, :state
  end
end
