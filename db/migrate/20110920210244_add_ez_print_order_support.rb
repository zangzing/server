class AddEzPrintOrderSupport < ActiveRecord::Migration
  def self.up
    #line_item
    add_column    :line_items, :print_photo_id, :bigint

    # add token to orders
    add_column    :orders, :ezp_reference_id, :string
    add_index     :orders, [:ezp_reference_id]
  end

  def self.down
    remove_column :line_items, :print_photo_id

    remove_column :orders, :ezp_reference_id
  end
end
