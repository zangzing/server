class AddWhoCanBuyPermission < ActiveRecord::Migration
  def self.up
    add_column    :albums, :who_can_buy,  :string, :default => Album::WHO_EVERYONE
  end

  def self.down
    remove_column    :albums, :who_can_buy
  end
end
