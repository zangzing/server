class AddPhotoForPrintFlag < ActiveRecord::Migration
  def self.up
    add_column :photos, :for_print, :boolean
  end

  def self.down
    remove_column :photos, :for_print
  end
end
