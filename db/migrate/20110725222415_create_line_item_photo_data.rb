class CreateLineItemPhotoData < ActiveRecord::Migration
  def self.up
     create_table :line_item_photo_data, :force => true do |t|
      t.integer :line_item_id
      t.column :photo_id, :bigint
      t.string :source_url
      t.string :crop_instructions
      t.timestamps
     end

      add_column :line_items, :photo_data_id, :bigint
  end

  def self.down
    drop_table :line_item_photo_data
    remove_column :line_items, :photo_data_id
  end
end