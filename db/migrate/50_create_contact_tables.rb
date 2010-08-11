class CreateContactTables < ActiveRecord::Migration
  def self.up
    create_table :identities, :guid => false,:force => true do |t|
      t.references_with_guid  :user
      t.string   :type
      t.string   :name
      t.string   :credentials , :limit => 400
      t.datetime :last_contact_refresh
      t.string   :identity_source
      t.timestamps
    end
    add_index :identities, :user_id

    create_table :contacts, :guid => false, :force => true do |t|
      t.integer :identity_id
      t.string  :type
      t.string  :name
      t.string  :address
      t.timestamps
    end
    add_index :contacts, :identity_id

  end

  def self.down
    drop_table :contacts
    drop_table :identities
  end
end
