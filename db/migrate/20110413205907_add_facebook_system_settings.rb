class AddFacebookSystemSettings < ActiveRecord::Migration
  def self.up
     add_column :system_settings, :description, :string
  end

  def self.down
    remove_column :system_settings, :description
  end
end
