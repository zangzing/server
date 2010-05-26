class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :identity_id
      t.string :name
      t.string :address

      t.timestamps
    end

    add_index :contacts, :identity_id


  end

  def self.down
    drop_table :contacts
  end
end
