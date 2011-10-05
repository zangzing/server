class AddShipmentToLineItem < ActiveRecord::Migration
  def self.up
    #line_item
      add_column    :line_items, :shipment_id, :integer
  end

  def self.down
      #line_item
      remove_column    :line_items, :shipment_id
  end
end
