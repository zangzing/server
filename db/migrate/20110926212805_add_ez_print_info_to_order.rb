class AddEzPrintInfoToOrder < ActiveRecord::Migration
  def self.up
    add_column    :orders, :test_mode, :boolean, :default => true
    add_column    :orders, :ezp_error_message, :string
  end

  def self.down
    remove_column :orders, :test_mode
    remove_column :orders, :ezp_error_message
  end
end
