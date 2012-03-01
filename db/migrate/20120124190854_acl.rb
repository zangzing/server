class Acl < ActiveRecord::Migration
  def self.up
    # first update the users table and set up my_group_id
    add_column :users, :my_group_id, :bigint
    add_column :users, :auto_by_contact, :boolean, :null => false, :default => false
    User.reset_column_information
    User.transaction do
      puts 'Ensuring all users have my_group_id set'
      User.all.each do |u|
        user_id = u.id
        group = Group.find_by_wrapped_user_id(user_id)
        u.my_group_id = group.id
        u.save(false) # save without the validations running
      end
      puts 'Done setting my_group_id'
    end

    create_table :acls, :force => true  do |t|
      t.column   :group_id,     :bigint,  :null => false
      t.column   :resource_id,  :bigint,  :null => false
      t.column   :role,         :integer, :null => false
    end
    # manually do alter to add enumerated type
    execute("ALTER TABLE acls ADD type ENUM('System', 'Album', 'Account') NOT NULL;")
    add_index    :acls, [:type, :resource_id, :group_id], :unique => true
    add_index    :acls, [:group_id]
  end

  def self.down
    remove_column :users, :my_group_id
    remove_column :users, :auto_by_contact
    drop_table :acls
  end
end
