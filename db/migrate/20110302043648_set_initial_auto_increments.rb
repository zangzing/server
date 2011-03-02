class SetInitialAutoIncrements < ActiveRecord::Migration
  def self.up
    execute('ALTER TABLE activities AUTO_INCREMENT = 77777;')
  end

  def self.down
  end
end
