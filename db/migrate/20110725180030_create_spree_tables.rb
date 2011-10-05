class CreateSpreeTables < ActiveRecord::Migration
     MIGRATIONS_PATH="./spree_zangzing/db/migrate"
     def self.up
       ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) DEFAULT NULL auto_increment PRIMARY KEY"
       ActiveRecord::Migrator.migrate MIGRATIONS_PATH
       ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT UNSIGNED DEFAULT NULL auto_increment PRIMARY KEY"
       # Load default data into commerce tables
       Rake::Task['db:load_dir'].invoke '../spree_zangzing/db/store_defaults'
     end

     def self.down
       Dir["#{MIGRATIONS_PATH}/[0-9]*_*.rb"].sort.reverse.
       map{|filename|require filename}.flatten.
       each{|class_name| const_get(class_name).down}
     end
end
