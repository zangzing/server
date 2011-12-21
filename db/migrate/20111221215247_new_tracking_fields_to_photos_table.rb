class NewTrackingFieldsToPhotosTable < ActiveRecord::Migration
  def self.up
    add_column :photos, :work_priority, :string
    add_column :photos, :import_context, :text
  end

  def self.down
    remove_column :photos, :work_priority
    remove_column :photos, :import_context

  end
end
