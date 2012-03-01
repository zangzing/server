class MarketingPrints < ActiveRecord::Migration
  def self.up
    add_column :line_items, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :line_items, :hidden
  end
end

