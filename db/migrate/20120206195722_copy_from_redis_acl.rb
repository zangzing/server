class CopyFromRedisAcl < ActiveRecord::Migration
  def self.up
    # bring in all the redis based acls and create appropriate
    # automatic users where acls is email based, also
    # backs up the current database
    ActiveRecord::Base.reset_column_information
    ActiveRecord::Base.send(:subclasses).each{|klass| klass.reset_column_information rescue nil}
    GroupsMigrationHelper.migrate_all
  end

  def self.down
  end
end
