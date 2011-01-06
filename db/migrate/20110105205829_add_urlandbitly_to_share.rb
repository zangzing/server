class AddUrlandbitlyToShare < ActiveRecord::Migration
  def self.up
    add_column :shares, :album_url, :string 
    add_column :shares, :bitly, :string
  end

  def self.down
    remove_column :shares, :album_url
    remove_column :shares, :bitly
  end
end
