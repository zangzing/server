class ZangzingModificationsForSpree < ActiveRecord::Migration
  def self.up
      #save default shipping and billing addresses
      add_column    :users, :ship_address_id, :integer
      add_column    :users, :bill_address_id, :integer

      # allow users to have multiple addresses
      add_column    :addresses, :user_id, :bigint
      add_index     :addresses, :user_id
  end

  def self.down
      remove_column    :users, :ship_address_id
      remove_column    :users, :bill_address_id
      
      remove_index     :addresses,  :user_id
      remove_column    :addresses, :user_id
  end
end
