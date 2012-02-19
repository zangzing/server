# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110407145731) do

  create_table "c_tracks", :id => false, :force => true do |t|
    t.integer "user_id",            :limit => 8, :null => false
    t.integer "tracked_id",         :limit => 8, :null => false
    t.integer "tracked_id_type",    :limit => 1, :null => false
    t.integer "track_type",         :limit => 1, :null => false
    t.integer "user_last_touch_at"
  end

  add_index "c_tracks", ["tracked_id"], :name => "index_c_tracks_on_tracked_id"
  add_index "c_tracks", ["user_id", "track_type", "tracked_id", "tracked_id_type"], :name => "track_info_index", :unique => true
  add_index "c_tracks", ["user_last_touch_at"], :name => "index_c_tracks_on_user_last_touch_at"

  create_table "c_versions", :id => false, :force => true do |t|
    t.integer "user_id",            :limit => 8, :null => false
    t.integer "track_type",         :limit => 1, :null => false
    t.integer "ver"
    t.integer "user_last_touch_at"
  end

  add_index "c_versions", ["user_id", "track_type"], :name => "index_c_versions_on_user_id_and_track_type", :unique => true
  add_index "c_versions", ["user_last_touch_at"], :name => "index_c_versions_on_user_last_touch_at"

  create_table "c_working_track_set", :id => false, :force => true do |t|
    t.integer "user_id",    :limit => 8, :null => false
    t.integer "track_type", :limit => 1, :null => false
    t.integer "tx_id",      :limit => 8, :null => false
  end

  add_index "c_working_track_set", ["tx_id"], :name => "index_c_working_track_set_on_tx_id"
  add_index "c_working_track_set", ["user_id", "track_type", "tx_id"], :name => "working_track_set_index", :unique => true

  create_table "test", :id => false, :force => true do |t|
    t.integer "user_id",    :limit => 8, :null => false
    t.integer "track_type", :limit => 1, :null => false
    t.integer "tx_id",      :limit => 8, :null => false
  end

end
