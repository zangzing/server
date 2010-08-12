# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 90) do

  create_table "activities", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "album_id"
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["album_id"], :name => "index_activities_on_album_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "albums", :force => true do |t|
    t.integer  "user_id"
    t.integer  "privacy"
    t.string   "type"
    t.string   "style",           :default => "white"
    t.boolean  "open"
    t.datetime "event_date"
    t.string   "location"
    t.integer  "stream_share_id"
    t.boolean  "reminders"
    t.string   "name"
    t.boolean  "suspended",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "albums", ["user_id"], :name => "index_albums_on_user_id"

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 20
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "contacts", :force => true do |t|
    t.integer  "identity_id"
    t.string   "type"
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["identity_id"], :name => "index_contacts_on_identity_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followee_id"
    t.boolean  "blocked",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followee_id"], :name => "index_follows_on_followee_id"
  add_index "follows", ["follower_id"], :name => "index_follows_on_follower_id"

  create_table "identities", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "name"
    t.string   "credentials"
    t.datetime "last_contact_refresh"
    t.string   "identity_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "agent_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 20
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "photos", :force => true do |t|
    t.integer  "album_id",                                    :null => false
    t.integer  "user_id",                                     :null => false
    t.string   "agent_id"
    t.string   "source_path"
    t.string   "state",                    :default => "new"
    t.text     "caption"
    t.text     "headline"
    t.datetime "capture_date"
    t.boolean  "suspended",                :default => false
    t.text     "metadata"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_path"
    t.string   "image_bucket"
    t.string   "local_image_file_name"
    t.string   "local_image_content_type"
    t.integer  "local_image_file_size"
    t.datetime "local_image_updated_at"
    t.string   "local_image_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["agent_id"], :name => "index_photos_on_agent_id"
  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"

  create_table "recipients", :force => true do |t|
    t.integer  "share_id"
    t.string   "type"
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recipients", ["share_id"], :name => "index_recipients_on_share_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shares", :force => true do |t|
    t.integer  "album_id"
    t.integer  "user_id"
    t.string   "type"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shares", ["album_id"], :name => "index_shares_on_album_id"
  add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                    :null => false
    t.string   "role",                :default => "user",  :null => false
    t.string   "user_name"
    t.string   "first_name",                               :null => false
    t.string   "last_name"
    t.string   "style",               :default => "white", :null => false
    t.string   "suspended",           :default => "f",     :null => false
    t.string   "crypted_password",                         :null => false
    t.string   "password_salt",                            :null => false
    t.string   "persistence_token",                        :null => false
    t.string   "single_access_token",                      :null => false
    t.string   "perishable_token",                         :null => false
    t.integer  "failed_login_count",  :default => 0,       :null => false
    t.date     "current_login_at"
    t.date     "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

end
