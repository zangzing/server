class AddErrorToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :error_message, :string
  end

  def self.down
    remove_column :photos, :error_message
  end
end
