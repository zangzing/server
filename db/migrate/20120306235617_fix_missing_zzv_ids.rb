class FixMissingZzvIds < ActiveRecord::Migration
  def self.up
    execute("update users set zzv_id = id where zzv_id is null")
  end

  def self.down
  end
end
