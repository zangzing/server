class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
        t.integer  :user_id
        t.integer  :privacy
        t.string   :type
        t.integer  :style, :default => "white"
        t.boolean  :open
        t.datetime :event_date
        t.string   :location
        t.integer  :stream_share_id
        t.boolean  :reminders
        t.string   :name
        t.boolean  :suspended , :default => false
        t.timestamps
    end
    add_index :albums, :user_id
  end

  def self.down
    drop_table :albums
  end
end
