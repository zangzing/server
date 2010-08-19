class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums, :force => true do |t|
        t.references_with_guid  :user
        t.references_with_guid  :cover_photo, :null => true
        t.string   :privacy, :default => 'public'
        t.string   :type
        t.string   :style, :default => "white"
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
