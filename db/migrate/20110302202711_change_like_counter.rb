class ChangeLikeCounter < ActiveRecord::Migration
  def self.up
      change_column :like_counters, :counter, :integer, :default => 0
  end

  def self.down
     change_column :like_counters, :counter, :integer
  end
end
