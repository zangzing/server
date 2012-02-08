class CopyFromRedisAcl < ActiveRecord::Migration
  def self.up
    # bring in all the redis based acls and create appropriate
    # automatic users where acls is email based, also
    # backs up the current database
    GroupsMigrationHelper.migrate_all
  end

  def self.down
  end
end
