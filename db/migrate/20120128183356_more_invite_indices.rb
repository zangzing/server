class MoreInviteIndices < ActiveRecord::Migration
  def self.up
    add_index :invitations, [:created_at]
    add_index :invitations, [:updated_at]
  end

  def self.down
  end
end
