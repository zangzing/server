class SetAlbumToStreamToEmailByDefault < ActiveRecord::Migration

  def self.up
      change_column :albums, :stream_to_email,    :boolean, :default => true
  end

  def self.down
    change_column :albums, :stream_to_email,    :boolean, :default => false
  end
end
