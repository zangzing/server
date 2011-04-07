class MakeCacheTables < ActiveRecord::Migration
  def self.up

    create_table :tracks, :id => false, :force => true do |t|
      t.column                 :user_id, :bigint, :null => false
      t.column                 :tracked_id, :bigint, :null => false
      t.column                 :tracked_id_type, :tinyint, :null => false
      t.column                 :track_type, :tinyint, :null => false
      t.integer                :user_last_touch_at
    end
    add_index :tracks, [:user_id, :track_type, :tracked_id, :tracked_id_type], :unique => true, :name => 'track_info_index'
    add_index :tracks, :user_last_touch_at
    add_index :tracks, :tracked_id

    create_table :working_track_set, :id => false, :force => true do |t|
      t.column                 :user_id, :bigint, :null => false
      t.column                 :track_type, :tinyint, :null => false
      t.column                 :tx_id, :bigint, :null => false
    end
    add_index :working_track_set, [:user_id, :track_type, :tx_id], :unique => true, :name => 'working_track_set_index'
    add_index :working_track_set, :tx_id

    create_table :versions, :id => false, :force => true do |t|
      t.column                 :user_id, :bigint, :null => false
      t.column                 :track_type, :tinyint, :null => false
      t.integer                :ver
    end
    add_index :versions, [:user_id, :track_type], :unique => true

  end

  def self.down
  end
end
