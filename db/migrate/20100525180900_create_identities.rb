class CreateIdentities < ActiveRecord::Migration
  def self.up
    create_table :identities do |t|
      t.integer :user_id
      t.string :credentials
      t.datetime :last_contact_refresh
      t.string :identity_source
      t.timestamps
    end

    add_index :identities, :user_id

  end

  def self.down
    drop_table :identities
  end
end
