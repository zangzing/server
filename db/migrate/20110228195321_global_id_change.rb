class GlobalIdChange < ActiveRecord::Migration
  def self.up

    create_table "activities", :force => true do |t|
      t.string   "type"
      t.column   :user_id, :bigint, :null => false
      t.column   :album_id, :bigint
      t.text     "payload"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "activities", ["album_id"], :name => "index_activities_on_album_id"
    add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

    create_table "albums", :force => true do |t|
      t.column   :user_id, :bigint, :null => false
      t.column   :cover_photo_id, :bigint
      t.string   "privacy",                              :default => "public"
      t.string   "type"
      t.string   "style",                                :default => "white"
      t.boolean  "open"
      t.datetime "event_date"
      t.string   "location"
      t.column   :stream_share_id, :bigint
      t.boolean  "reminders"
      t.string   "name"
      t.boolean  "suspended",                            :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "picon_content_type"
      t.integer  "picon_file_size"
      t.string   "picon_path"
      t.string   "picon_bucket"
      t.datetime "picon_updated_at"
      t.string   "email"
      t.datetime "photos_last_updated_at",               :default => '2011-02-28 20:49:28', :null => false
      t.boolean  "custom_order",                         :default => false
    end


    add_index "albums", ["user_id"], :name => "index_albums_on_user_id"

    create_table "bench_test_photo_gens", :force => true do |t|
      t.string   "result_message"
      t.datetime "start"
      t.datetime "stop"
      t.integer  "iterations"
      t.integer  "file_size"
      t.column   :album_id, :bigint
      t.column   :user_id, :bigint
      t.integer  "error_count"
      t.integer  "good_count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    create_table "bench_test_resque_no_ops", :force => true do |t|
      t.string   "result_message"
      t.datetime "start"
      t.datetime "stop"
      t.integer  "iterations"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    create_table "bench_test_s3s", :force => true do |t|
      t.string   "result_message"
      t.datetime "start"
      t.datetime "stop"
      t.integer  "iterations"
      t.integer  "file_size"
      t.boolean  "upload"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    create_table "client_applications", :force => true do |t|
      t.string   "name"
      t.string   "url"
      t.string   "support_url"
      t.string   "callback_url"
      t.string   "key",          :limit => 20
      t.string   "secret",       :limit => 40
      t.column   :user_id, :bigint, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

    create_table "contacts", :force => true do |t|
      t.column   :identity_id, :bigint
      t.string   "type"
      t.string   "name"
      t.string   "address"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "contacts", ["identity_id"], :name => "index_contacts_on_identity_id"

    create_table "contributors", :force => true do |t|
      t.column   :album_id, :bigint, :null => false
      t.column   :user_id, :bigint
      t.string   "name"
      t.string   "email"
      t.datetime "last_contribution"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "contributors", ["album_id"], :name => "index_contributors_on_album_id"
    add_index "contributors", ["email", "album_id"], :name => "email_album_unique_index", :unique => true
    add_index "contributors", ["email"], :name => "index_contributors_on_email"


    create_table "follows", :force => true do |t|
      t.column   :follower_id, :bigint, :null => false
      t.column   :followed_id, :bigint, :null => false
      t.boolean  "blocked",                   :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "follows", ["followed_id"], :name => "index_follows_on_followed_id"
    add_index "follows", ["follower_id"], :name => "index_follows_on_follower_id"

    create_table "identities", :force => true do |t|
      t.column   :user_id, :bigint, :null => false
      t.string   "type"
      t.string   "name"
      t.string   "credentials",          :limit => 2048
      t.datetime "last_contact_refresh"
      t.string   "identity_source"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "identities", ["user_id"], :name => "index_identities_on_user_id"


    create_table "like_counters", :force => true do |t|
      t.column   :subject_id, :bigint
      t.integer "counter"
    end


    add_index "like_counters", ["subject_id"], :name => "index_like_counters_on_subject_id", :unique => true

    create_table "likes", :force => true do |t|
      t.column   :user_id, :bigint, :null => false
      t.column   :subject_id, :bigint, :null => false
      t.string "subject_type",               :null => false
    end


    add_index "likes", ["subject_id"], :name => "index_likes_on_subject_id"
    add_index "likes", ["user_id", "subject_id"], :name => "userid_subjectid_index", :unique => true
    add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

    create_table "oauth_nonces", :force => true do |t|
      t.string   "nonce"
      t.integer  "timestamp"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

    create_table "oauth_tokens", :force => true do |t|
      t.column   :user_id, :bigint
      t.string   "agent_id",              :limit => 64
      t.string   "type",                  :limit => 20
      t.column   :client_application_id, :bigint
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

    create_table "photo_infos", :force => true do |t|
      t.column   :photo_id, :bigint, :null => false
      t.binary "metadata"
    end


    add_index "photo_infos", ["photo_id"], :name => "index_photo_infos_on_photo_id"

    create_table "photos", :force => true do |t|
      t.column   :album_id, :bigint, :null => false
      t.column   :user_id, :bigint, :null => false
      t.column   :upload_batch_id, :bigint
      t.string   "agent_id",                        :limit => 64
      t.string   "guid_part",                       :limit => 36
      t.string   "source_path"
      t.string   "state",                            :default => "assigned"
      t.text     "caption"
      t.text     "headline"
      t.datetime "capture_date"
      t.boolean  "suspended",                        :default => false
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      t.string   "image_path"
      t.string   "image_bucket"
      t.string   "source_thumb_url"
      t.string   "source_screen_url"
      t.string   "source_guid"
      t.string   "error_message"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "height"
      t.integer  "width"
      t.integer  "orientation"
      t.float    "latitude"
      t.float    "longitude"
      t.integer  "rotate_to",                        :default => 0
      t.datetime "generate_queued_at",               :default => '1970-01-01 00:00:00', :null => false
      t.float    "pos"
    end


    add_index "photos", ["agent_id"], :name => "index_photos_on_agent_id"
    add_index "photos", ["album_id"], :name => "index_photos_on_album_id"
    add_index "photos", ["upload_batch_id"], :name => "index_photos_on_upload_batch_id"
    add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

    create_table "recipients", :force => true do |t|
      t.column   :share_id, :bigint
      t.string   "service"
      t.string   "name"
      t.string   "address"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "recipients", ["share_id"], :name => "index_recipients_on_share_id"

    create_table "sessions", :force => true do |t|
      t.column   :session_id, :bigint, :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end


    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "shares", :force => true do |t|
      t.column   :album_id, :bigint, :null => false
      t.column   :user_id, :bigint, :null => false
      t.string   "type"
      t.string   "subject"
      t.text     "message"
      t.datetime "sent_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "album_url"
      t.string   "bitly"
    end


    add_index "shares", ["album_id"], :name => "index_shares_on_album_id"
    add_index "shares", ["user_id", "album_id"], :name => "userid_albumid_index"
    add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

    create_table "slugs", :force => true do |t|
      t.string   "name"
      t.column   :sluggable_id, :bigint, :null => false
      t.integer  "sequence",                     :default => 1, :null => false
      t.string   "sluggable_type", :limit => 40
      t.string   "scope"
      t.datetime "created_at"
    end


    add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

    create_table "upload_batches", :force => true do |t|
      t.column   :album_id, :bigint, :null => false
      t.column   :user_id, :bigint, :null => false
      t.string   "state",                             :default => "open"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.float    "custom_order_offset",               :default => 0.0
    end


    add_index "upload_batches", ["album_id"], :name => "index_upload_batches_on_album_id"
    add_index "upload_batches", ["user_id"], :name => "index_upload_batches_on_user_id"

    create_table "users", :force => true do |t|
      t.string   "email",                                                  :null => false
      t.string   "role",                              :default => "user",  :null => false
      t.string   "username"
      t.string   "first_name",                                             :null => false
      t.string   "last_name"
      t.string   "style",                             :default => "white", :null => false
      t.string   "crypted_password",                                       :null => false
      t.string   "password_salt",                                          :null => false
      t.string   "persistence_token",                                      :null => false
      t.string   "single_access_token",                                    :null => false
      t.string   "perishable_token",                                       :null => false
      t.integer  "failed_login_count",                :default => 0,       :null => false
      t.date     "current_login_at"
      t.date     "last_login_at"
      t.string   "current_login_ip"
      t.string   "last_login_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "active",                            :default => true,    :null => false
      t.boolean  "approved",                          :default => true,    :null => false
      t.boolean  "automatic",                         :default => false
    end


    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
    add_index "users", ["username"], :name => "index_users_on_username", :unique => true


  end

  def self.down
  end
end
