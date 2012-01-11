class CreateTrackedLinkTableAndInvitationsTable < ActiveRecord::Migration
  def self.up
    create_table :tracked_links, :force => true do |t|
      t.string :tracking_token, :default => false, :null => false
      t.string :link_type, :default => false
      t.string :url, :default => false
      t.string :shared_to, :default => false
      t.string :shared_to_address, :default => false
      t.column :user_id, :bigint, :null => true
      t.integer :visit_count, :default => 0
      t.integer :join_count, :default => 0
    end
    add_index :tracked_links, :user_id
    add_index :tracked_links, :tracking_token, :unique => true

    create_table :invitations, :force => true do |t|
      t.column :user_id, :bigint, :null => false
      t.column :invited_user_id, :bigint, :null => true
      t.column :tracked_link_id, :bigint, :null => true
      t.string :email, :default => false
      t.string :status, :default => false
    end
    add_index :invitations, :user_id
    add_index :invitations, :invited_user_id


  end

  def self.down
    drop_table :tracked_links
    drop_table :invitations
  end

end
