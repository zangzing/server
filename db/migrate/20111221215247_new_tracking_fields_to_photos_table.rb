class NewTrackingFieldsToPhotosTable < ActiveRecord::Migration
  def self.up
    add_column :photos, :work_priority, :integer
    add_column :photos, :import_context, :string, :limit => 16384
  end

  def self.down
    remove_column :photos, :work_priority
    remove_column :photos, :import_context

  end
end
