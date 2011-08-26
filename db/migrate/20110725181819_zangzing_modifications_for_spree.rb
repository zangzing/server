class ZangzingModificationsForSpree < ActiveRecord::Migration
  def self.up
      #save default shipping and billing addresses
      add_column    :users, :ship_address_id, :integer
      add_column    :users, :bill_address_id, :integer
      add_column    :users, :creditcard_id,   :integer

      # allow users to have multiple addresses
      add_column    :addresses, :user_id, :bigint
      add_index     :addresses, :user_id

      #allow users to have multiple credit cards
      add_column    :creditcards, :user_id, :bigint
      add_index     :creditcards, :user_id

      # add token to orders
      add_column    :orders, :guest, :boolean, :default => :false
      add_column    :orders, :token, :string
  end

  def self.down
      remove_column    :users, :ship_address_id
      remove_column    :users, :bill_address_id
      
      remove_index     :addresses,  :user_id
      remove_column    :addresses, :user_id

      remove_column    :orders, :token
  end
end
