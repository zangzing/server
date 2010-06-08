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

ActiveRecord::Schema.define(:version => 20100607171606) do

  create_table "albums", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "albums", ["user_id"], :name => "index_albums_on_user_id"

  create_table "contacts", :force => true do |t|
    t.integer  "identity_id"
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

  create_table "identities", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "credentials"
    t.datetime "last_contact_refresh"
    t.string   "identity_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "photos", :force => true do |t|
    t.integer  "album_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "local_image_file_name"
    t.string   "local_image_content_type"
    t.integer  "local_image_file_size"
    t.datetime "local_image_updated_at"
    t.string   "state",                    :default => "new"
  end

  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"

  create_table "shares", :force => true do |t|
    t.integer  "album_id"
    t.integer  "user_id"
    t.string   "email_to"
    t.string   "email_subject"
    t.text     "email_message"
    t.string   "twitter_message"
    t.string   "facebook_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shares", ["album_id"], :name => "index_shares_on_album_id"
  add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.string   "remember_token"
    t.boolean  "admin"
    t.string   "style",              :default => "white"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
