class AddShareType < ActiveRecord::Migration
  def self.up
    add_column    :shares, :share_type, :string
  end

  def self.down
    remove_column :shares, :share_type
  end
end
