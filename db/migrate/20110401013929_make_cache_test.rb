class MakeCacheTest < ActiveRecord::Migration
  def self.up
    create_table :tracks, :id => false, :force => true do |t|
      t.column                 :user_id, :bigint, :null => false
      t.column                 :tracked_id, :bigint, :null => false
      t.column                 :track_type, :tinyint, :null => false
      t.integer                :user_last_touch_at
    end
    add_index :tracks, [:user_id, :tracked_id, :track_type], :unique => true
    add_index :tracks, :user_last_touch_at
  end

  def self.down
  end
end
