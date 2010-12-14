class CreateUploadBatches < ActiveRecord::Migration
  def self.up
    create_table :upload_batches,:guid => false,:force => true do |t|
      t.references_with_guid  :album
      t.references_with_guid  :user
      t.string :state, :default => 'open'
      t.timestamps
    end
    add_index :upload_batches, :id, :unique  => true
    add_index :upload_batches, :album_id
    add_index :upload_batches, :user_id
  end

  def self.down
      drop_table :upload_batches
  end
end

