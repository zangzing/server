class ConvertRolesToAcLs < ActiveRecord::Migration
  def self.up
    # safely convert database user roles to acl roles
    # if a role already exists in acl does not change
    OldSystemRightsACL.convert_db_users

    # now we can git rid of the old role column
    remove_column :users, :role
  end

  def self.down
  end
end
