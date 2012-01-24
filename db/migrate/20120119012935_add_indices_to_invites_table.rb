class AddIndicesToInvitesTable < ActiveRecord::Migration
  def self.up
    add_index :invitations, [:tracked_link_id]
    add_index :invitations, [:email]
    change_column :invitations, :email, :string, :null=>true, :default => nil
    change_column :invitations, :status, :string, :null=>true, :default => nil

  end

  def self.down
  end
end
