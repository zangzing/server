class Groups < ActiveRecord::Migration
  def self.up
    # define group related tables
    create_table :groups  do |t|
      t.column   :user_id,     :bigint,  :null => false
      t.column   :name,        :string,  :null => false
      t.column   :wrapped_user_id, :bigint
      t.timestamps
    end
    add_index    :groups, [:wrapped_user_id], :unique => true
    add_index    :groups, [:user_id, :name], :unique => true

    create_table :group_members  do |t|
      t.column   :group_id,    :bigint,  :null => false
      t.column   :user_id,     :bigint,  :null => false
    end
    add_index    :group_members, [:group_id, :user_id], :unique => true
    add_index    :group_members, [:user_id]

    User.transaction do
      User.all.each do |u|
        user_id = u.id
        Group.create_wrapped_user(user_id)
      end
      puts 'Added group wrapper to all existing users'
    end
  end

  def self.down
#    drop_table :acls
    drop_table :groups
    drop_table :group_members
  end
end
