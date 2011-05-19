class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :test_migrate1, :force => true do |t|
     t.string    :dummy,  :null => :false
    end
  end

  def self.down
  end
end
