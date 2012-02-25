class AddCreatedByUser < ActiveRecord::Migration
  def self.up
    add_column    :users, :created_by_user_id, :bigint
    add_index     :users, [:created_by_user_id]

    add_index     :acls, [:type, :group_id]
  end

  def self.down
    remove_column :users, :created_by_user_id
  end
end
