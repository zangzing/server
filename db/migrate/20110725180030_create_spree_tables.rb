class CreateSpreeTables < ActiveRecord::Migration
     MIGRATIONS_PATH='spree-0-60-1/migrate'
     def self.up
       ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "int(11) DEFAULT NULL auto_increment PRIMARY KEY"
       Dir["#{MIGRATIONS_PATH}/[0-9]*_*.rb"].
       sort.map{|filename|require filename}.flatten.
       each{|class_name| const_get(class_name).up}
       ActiveRecord::ConnectionAdapters::Mysql2Adapter::NATIVE_DATABASE_TYPES[:primary_key] = "BIGINT UNSIGNED DEFAULT NULL auto_increment PRIMARY KEY"
     end

     def self.down
       Dir["#{MIGRATIONS_PATH}/[0-9]*_*.rb"].sort.reverse.
       map{|filename|require filename}.flatten.
       each{|class_name| const_get(class_name).down}
     end
end
