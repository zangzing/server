class AddEzPrintSupport < ActiveRecord::Migration
  def self.up
    add_column :photos, :crop_json, :string
    add_column :albums, :for_print, :boolean
  end

  def self.down
    remove_column :photos, :crop_json
    remove_column :albums, :for_print
  end
end
