class NullRotation < ActiveRecord::Migration
  def self.up
    # doing this directly because migrations don't support setting back to default of null
    execute("ALTER TABLE photos MODIFY rotate_to int(11) default null;")
  end

  def self.down
    execute("ALTER TABLE photos MODIFY rotate_to int(11) default 0;")
  end
end
