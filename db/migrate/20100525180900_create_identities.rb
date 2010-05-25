class CreateIdentities < ActiveRecord::Migration
  def self.up
    create_table :identities do |t|
      t.string :credentials
      t.datetime :last_contact_refresh
      t.string :identity_source

      t.timestamps
    end
  end

  def self.down
    drop_table :identities
  end
end
