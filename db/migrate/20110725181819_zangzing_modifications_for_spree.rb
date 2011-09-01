class ZangzingModificationsForSpree < ActiveRecord::Migration
  def self.up
      #line_item
      add_column    :line_items, :photo_id, :bigint
      add_column    :line_items, :crop_instructions, :string
      add_column    :line_items,  :back_message, :string

      #save default shipping and billing addresses
      add_column    :users, :ship_address_id, :integer
      add_column    :users, :bill_address_id, :integer
      add_column    :users, :creditcard_id,   :integer

      # allow users to have multiple addresses
      add_column    :addresses, :user_id, :bigint
      add_index     :addresses, :user_id

      #allow users to have multiple credit cards
      add_column    :creditcards, :payment_method_id, :integer
      add_column    :creditcards, :user_id, :bigint
      add_index     :creditcards, :user_id

      # add token to orders
      add_column    :orders, :guest, :boolean, :default => :false
      add_column    :orders, :token, :string
  end

  def self.down
      remove_column :line_items, :photo_id
      remove_column :line_items, :crop_instructions
      remove_column :line_items,  :back_message

      remove_column :users, :ship_address_id
      remove_column :users, :bill_address_id
      remove_column :users, :creditcard_id

      remove_index  :addresses,  :user_id
      remove_column :addresses, :user_id

      remove_column :creditcards, :payment_method_id
      remove_column :creditcards, :user_id
      remove_index  :creditcards, :user_id

      remove_column :orders, :token
      remove_column :orders, :guest
  end
end
