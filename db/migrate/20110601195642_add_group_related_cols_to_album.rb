class AddGroupRelatedColsToAlbum < ActiveRecord::Migration
  def self.up
    add_column    :albums, :stream_to_email,    :boolean, :default => false
    add_column    :albums, :stream_to_facebook, :boolean, :default => false
    add_column    :albums, :stream_to_twitter,  :boolean, :default => false

    add_column    :albums, :who_can_download,  :string, :default => Album::WHO_OWNER
    add_column    :albums, :who_can_upload,    :string, :default => Album::WHO_CONTRIBUTORS
  end

  def self.down
    remove_column    :albums, :stream_to_email
    remove_column    :albums, :stream_to_facebook
    remove_column    :albums, :stream_to_twitter

    remove_column    :albums, :who_can_download
    remove_column    :albums, :who_can_upload
  end

end
