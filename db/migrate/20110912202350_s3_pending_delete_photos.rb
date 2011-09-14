class S3PendingDeletePhotos < ActiveRecord::Migration
  def self.up
    create_table :s3_pending_delete_photos  do |t|
      t.column   :photo_id,       :bigint,  :null => false
      t.column   :user_id,        :bigint,  :null => false
      t.column   :album_id,       :bigint,  :null => false
      t.column   :prefix,         :string,  :null => false
      t.column   :guid_part,      :string,  :null => false
      t.column   :image_bucket,   :string,  :null => false
      t.column   :encoded_sizes,  :string,  :null => false
      t.column   :caption,        :string
      t.column   :deleted_at,     :datetime, :null => false
    end

    add_index    :s3_pending_delete_photos, [:photo_id]
    add_index    :s3_pending_delete_photos, [:user_id]
    add_index    :s3_pending_delete_photos, [:album_id]
    add_index    :s3_pending_delete_photos, [:deleted_at]

    execute("ALTER TABLE s3_pending_delete_photos AUTO_INCREMENT = 289900073723;")

  end

  def self.down
    drop_table :s3_pending_delete_photos
  end
end
