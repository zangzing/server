class ZangzingModificationsForSpree < ActiveRecord::Migration
  def self.up

    #  ZZ_ADD_TO_USER t.integer  "ship_address_id"
    #  ZZ_ADD TO_USER t.integer  "bill_address_id"
      add_column    :users, :ship_address_id, :integer
      add_column    :users, :bill_address_id, :integer
  end

  def self.down
      remove_column    :users, :ship_address_id
      remove_column    :users, :bill_address_id
  end
end
