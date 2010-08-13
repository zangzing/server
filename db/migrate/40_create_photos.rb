class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
         t.references_with_guid  :album
         t.references_with_guid  :user
         t.string   :agent_id
         t.string   :source_path
         t.string   :state,                    :default => "new"
         t.text     :caption
         t.text     :headline
         t.datetime :capture_date
         t.boolean  :suspended,                :default => false
         t.text     :metadata
         t.string   :image_file_name
         t.string   :image_content_type
         t.integer  :image_file_size
         t.datetime :image_updated_at
         t.string   :image_path
         t.string   :image_bucket
         t.string   :local_image_file_name
         t.string   :local_image_content_type
         t.integer  :local_image_file_size
         t.datetime :local_image_updated_at
         t.string   :local_image_path
                  
         t.timestamps  
       end
       add_index :photos, :album_id
       add_index :photos, :agent_id      
  end
  def self.down
    drop_table :photos
  end
end
