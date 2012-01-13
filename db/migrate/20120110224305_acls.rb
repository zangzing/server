class Acls < ActiveRecord::Migration
  def self.up
    # doing this directly because migrations don't support ENUMs
    execute("
CREATE TABLE acls (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  type ENUM('SystemRights', 'Album', 'SharedUser') NOT NULL,
  group_id bigint(20) unsigned NOT NULL,
  resource_id bigint(20) unsigned NOT NULL,
  role tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `index_type_resource_id_group_id` (type, resource_id, group_id),
  KEY `index_group_id` (group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
")
    # also define group related tables
    create_table :groups  do |t|
      t.column   :user_id,     :bigint,  :null => false
      t.column   :name,        :string,  :null => false
      t.column   :wrapped_user_id, :bigint
    end
    add_index    :groups, [:user_id]
    add_index    :groups, [:wrapped_user_id]
    add_index    :groups, [:user_id, :name], :unique => true

    create_table :group_members  do |t|
      t.column   :group_id,    :bigint,  :null => false
      t.column   :user_id,     :bigint,  :null => false
      t.column   :email_id,    :bigint
    end
    add_index    :group_members, [:group_id, :user_id], :unique => true
    add_index    :group_members, [:user_id]

  end

  def self.down
    drop_table :acls
    drop_table :groups
    drop_table :group_members
  end
end
