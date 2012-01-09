class SetAlbumToHiddenByDefault < ActiveRecord::Migration
  def self.up
    change_column    :albums, :privacy, :string, :default => Album::HIDDEN
  end

  def self.down
  end
end
