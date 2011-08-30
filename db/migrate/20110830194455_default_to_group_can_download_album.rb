class DefaultToGroupCanDownloadAlbum < ActiveRecord::Migration
  def self.up
    change_column    :albums, :who_can_download,  :string, :default => Album::WHO_VIEWERS

  end

  def self.down
  end
end
