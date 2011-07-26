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

ActiveRecord::Schema.define(:version => 20110725222415) do

  create_table "activities", :force => true do |t|
    t.string   "type"
    t.integer  "user_id",      :limit => 8, :null => false
    t.integer  "subject_id",   :limit => 8
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_id",     :limit => 8
    t.string   "subject_type",              :null => false
  end

  add_index "activities", ["subject_id", "subject_type"], :name => "index_activities_on_subject_id_and_subject_type"
  add_index "activities", ["user_id", "subject_id", "subject_type"], :name => "index_activities_on_user_id_and_subject_id_and_subject_type"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "addresses", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zipcode"
    t.integer  "country_id"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state_name"
    t.string   "alternative_phone"
  end

  add_index "addresses", ["firstname"], :name => "index_addresses_on_firstname"
  add_index "addresses", ["lastname"], :name => "index_addresses_on_lastname"

  create_table "adjustments", :force => true do |t|
    t.integer  "order_id"
    t.decimal  "amount",          :precision => 8, :scale => 2
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.string   "source_type"
    t.boolean  "mandatory"
    t.boolean  "locked"
    t.integer  "originator_id"
    t.string   "originator_type"
  end

  add_index "adjustments", ["order_id"], :name => "index_adjustments_on_order_id"

  create_table "albums", :force => true do |t|
    t.integer  "user_id",                :limit => 8,                                    :null => false
    t.integer  "cover_photo_id",         :limit => 8
    t.string   "privacy",                             :default => "public"
    t.string   "type"
    t.string   "style",                               :default => "white"
    t.boolean  "open"
    t.datetime "event_date"
    t.string   "location"
    t.integer  "stream_share_id",        :limit => 8
    t.boolean  "reminders"
    t.string   "name"
    t.boolean  "suspended",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picon_content_type"
    t.integer  "picon_file_size"
    t.string   "picon_path"
    t.string   "picon_bucket"
    t.datetime "picon_updated_at"
    t.string   "email"
    t.datetime "photos_last_updated_at",              :default => '2011-02-28 20:49:28', :null => false
    t.boolean  "custom_order",                        :default => false
    t.integer  "completed_batch_count",               :default => 0
    t.datetime "deleted_at"
    t.integer  "cache_version",          :limit => 8, :default => 0
    t.boolean  "stream_to_email",                     :default => true
    t.boolean  "stream_to_facebook",                  :default => false
    t.boolean  "stream_to_twitter",                   :default => false
    t.string   "who_can_download",                    :default => "owner"
    t.string   "who_can_upload",                      :default => "contributors"
  end

  add_index "albums", ["deleted_at"], :name => "index_albums_on_deleted_at"
  add_index "albums", ["user_id"], :name => "index_albums_on_user_id"

  create_table "assets", :force => true do |t|
    t.integer  "viewable_id"
    t.string   "viewable_type",           :limit => 50
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.integer  "attachment_size"
    t.integer  "position"
    t.string   "type",                    :limit => 75
    t.datetime "attachment_updated_at"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.text     "alt"
  end

  add_index "assets", ["viewable_id"], :name => "index_assets_on_viewable_id"
  add_index "assets", ["viewable_type", "type"], :name => "index_assets_on_viewable_type_and_type"

  create_table "bench_test_photo_gens", :force => true do |t|
    t.string   "result_message"
    t.datetime "start"
    t.datetime "stop"
    t.integer  "iterations"
    t.integer  "file_size"
    t.integer  "album_id",       :limit => 8
    t.integer  "user_id",        :limit => 8
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

  create_table "bulk_id_generators", :force => true do |t|
    t.string  "table_name",                                :null => false
    t.integer "next_start_id", :limit => 8,                :null => false
    t.integer "batch_size",                                :null => false
    t.integer "lock_version",               :default => 0
  end

  add_index "bulk_id_generators", ["table_name"], :name => "index_bulk_id_generators_on_table_name", :unique => true

  create_table "calculators", :force => true do |t|
    t.string   "type"
    t.integer  "calculable_id",   :null => false
    t.string   "calculable_type", :null => false
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
    t.integer  "user_id",      :limit => 8,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "configurations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :limit => 50
  end

  add_index "configurations", ["name", "type"], :name => "index_configurations_on_name_and_type"

  create_table "contacts", :force => true do |t|
    t.integer  "identity_id", :limit => 8
    t.string   "type"
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["identity_id"], :name => "index_contacts_on_identity_id"

  create_table "contributors", :force => true do |t|
    t.integer  "album_id",          :limit => 8, :null => false
    t.integer  "user_id",           :limit => 8
    t.string   "name"
    t.string   "email"
    t.datetime "last_contribution"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contributors", ["album_id"], :name => "index_contributors_on_album_id"
  add_index "contributors", ["email", "album_id"], :name => "email_album_unique_index", :unique => true
  add_index "contributors", ["email"], :name => "index_contributors_on_email"

  create_table "countries", :force => true do |t|
    t.string  "iso_name"
    t.string  "iso"
    t.string  "name"
    t.string  "iso3"
    t.integer "numcode"
  end

  create_table "coupons", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.integer  "usage_limit"
    t.boolean  "combine"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
  end

  create_table "creditcards", :force => true do |t|
    t.string   "month"
    t.string   "year"
    t.string   "cc_type"
    t.string   "last_digits"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_month"
    t.string   "start_year"
    t.string   "issue_number"
    t.integer  "address_id"
    t.string   "gateway_customer_profile_id"
    t.string   "gateway_payment_profile_id"
  end

  create_table "email_templates", :force => true do |t|
    t.integer  "email_id",                       :null => false
    t.string   "name",                           :null => false
    t.string   "mc_campaign_id", :default => ""
    t.string   "from_name"
    t.string   "from_address"
    t.string   "reply_to"
    t.string   "subject"
    t.string   "category"
    t.text     "html_content"
    t.text     "text_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_templates", ["name"], :name => "index_email_templates_on_name"

  create_table "emails", :force => true do |t|
    t.string  "name",                   :null => false
    t.integer "production_template_id"
    t.text    "params"
    t.text    "method"
  end

  add_index "emails", ["name"], :name => "index_emails_on_name"

  create_table "follows", :force => true do |t|
    t.integer  "follower_id", :limit => 8,                    :null => false
    t.integer  "followed_id", :limit => 8,                    :null => false
    t.boolean  "blocked",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followed_id"], :name => "index_follows_on_followed_id"
  add_index "follows", ["follower_id"], :name => "index_follows_on_follower_id"

  create_table "gateways", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.string   "server",      :default => "test"
    t.boolean  "test_mode",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guests", :force => true do |t|
    t.string   "email"
    t.string   "source"
    t.integer  "user_id",    :limit => 8
    t.string   "status",                  :default => "Pending Signup"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guests", ["email"], :name => "index_guests_on_email", :unique => true

  create_table "identities", :force => true do |t|
    t.integer  "user_id",              :limit => 8,    :null => false
    t.string   "type"
    t.string   "name"
    t.string   "credentials",          :limit => 2048
    t.datetime "last_contact_refresh"
    t.string   "identity_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "inventory_units", :force => true do |t|
    t.integer  "variant_id"
    t.integer  "order_id"
    t.string   "state"
    t.integer  "lock_version",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipment_id"
    t.integer  "return_authorization_id"
  end

  add_index "inventory_units", ["order_id"], :name => "index_inventory_units_on_order_id"
  add_index "inventory_units", ["shipment_id"], :name => "index_inventory_units_on_shipment_id"
  add_index "inventory_units", ["variant_id"], :name => "index_inventory_units_on_variant_id"

  create_table "like_counters", :force => true do |t|
    t.integer "subject_id",   :limit => 8
    t.integer "counter",                   :default => 0
    t.string  "subject_type"
  end

  add_index "like_counters", ["subject_id", "subject_type"], :name => "index_like_counters_on_subject_id_and_subject_type", :unique => true

  create_table "likes", :force => true do |t|
    t.integer "user_id",      :limit => 8, :null => false
    t.integer "subject_id",   :limit => 8, :null => false
    t.string  "subject_type",              :null => false
  end

  add_index "likes", ["subject_id"], :name => "index_likes_on_subject_id"
  add_index "likes", ["user_id", "subject_id", "subject_type"], :name => "index_likes_on_user_id_and_subject_id_and_subject_type", :unique => true
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "line_item_photo_data", :force => true do |t|
    t.integer  "line_item_id"
    t.integer  "photo_id",          :limit => 8
    t.string   "source_url"
    t.string   "crop_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "variant_id"
    t.integer  "quantity",                                 :null => false
    t.decimal  "price",      :precision => 8, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["variant_id"], :name => "index_line_items_on_variant_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_methods", :force => true do |t|
    t.string   "environment"
    t.boolean  "active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailing_lists", :force => true do |t|
    t.string   "name"
    t.string   "mailchimp_list_id", :null => false
    t.string   "category",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mailing_lists", ["category"], :name => "index_mailing_lists_on_category"
  add_index "mailing_lists", ["mailchimp_list_id"], :name => "index_mailing_lists_on_mailchimp_list_id", :unique => true

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id",               :limit => 8
    t.string   "agent_id",              :limit => 64
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id", :limit => 8
    t.string   "token",                 :limit => 20
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "agent_version"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "option_types", :force => true do |t|
    t.string   "name",         :limit => 100
    t.string   "presentation", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                    :default => 0, :null => false
  end

  create_table "option_types_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "option_type_id"
  end

  create_table "option_values", :force => true do |t|
    t.integer  "option_type_id"
    t.string   "name"
    t.integer  "position"
    t.string   "presentation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "option_values_variants", :id => false, :force => true do |t|
    t.integer "variant_id"
    t.integer "option_value_id"
  end

  add_index "option_values_variants", ["variant_id", "option_value_id"], :name => "index_option_values_variants_on_variant_id_and_option_value_id"
  add_index "option_values_variants", ["variant_id"], :name => "index_option_values_variants_on_variant_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id",              :limit => 8
    t.string   "number",               :limit => 15
    t.decimal  "item_total",                         :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "total",                              :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.decimal  "adjustment_total",                   :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "credit_total",                       :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "completed_at"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.decimal  "payment_total",                      :precision => 8, :scale => 2, :default => 0.0
    t.integer  "shipping_method_id"
    t.string   "shipment_state"
    t.string   "payment_state"
    t.string   "email"
    t.text     "special_instructions"
  end

  add_index "orders", ["number"], :name => "index_orders_on_number"

  create_table "payment_methods", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "display_on"
  end

  create_table "payments", :force => true do |t|
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",            :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "payment_method_id"
    t.string   "state"
    t.string   "response_code"
    t.string   "avs_response"
  end

  create_table "photo_infos", :force => true do |t|
    t.integer "photo_id", :limit => 8, :null => false
    t.binary  "metadata"
  end

  add_index "photo_infos", ["photo_id"], :name => "index_photo_infos_on_photo_id"

  create_table "photos", :force => true do |t|
    t.integer  "album_id",           :limit => 8,                                     :null => false
    t.integer  "user_id",            :limit => 8,                                     :null => false
    t.integer  "upload_batch_id",    :limit => 8
    t.string   "agent_id",           :limit => 64
    t.string   "guid_part",          :limit => 36
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
    t.integer  "rotate_to"
    t.datetime "generate_queued_at",               :default => '1970-01-01 00:00:00', :null => false
    t.float    "pos"
    t.string   "source"
    t.datetime "deleted_at"
  end

  add_index "photos", ["agent_id"], :name => "index_photos_on_agent_id"
  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"
  add_index "photos", ["created_at"], :name => "index_photos_on_created_at"
  add_index "photos", ["deleted_at"], :name => "index_photos_on_deleted_at"
  add_index "photos", ["pos", "created_at"], :name => "index_photos_on_pos_and_created_at"
  add_index "photos", ["upload_batch_id"], :name => "index_photos_on_upload_batch_id"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

  create_table "preferences", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.integer  "owner_id",                  :null => false
    t.string   "owner_type", :limit => 50,  :null => false
    t.integer  "group_id"
    t.string   "group_type", :limit => 50
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["owner_id", "owner_type", "name", "group_id", "group_type"], :name => "ix_prefs_on_owner_attr_pref", :unique => true

  create_table "product_groups", :force => true do |t|
    t.string "name"
    t.string "permalink"
    t.string "order"
  end

  add_index "product_groups", ["name"], :name => "index_product_groups_on_name"
  add_index "product_groups", ["permalink"], :name => "index_product_groups_on_permalink"

  create_table "product_groups_products", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_group_id"
  end

  create_table "product_option_types", :force => true do |t|
    t.integer  "product_id"
    t.integer  "option_type_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_properties", :force => true do |t|
    t.integer  "product_id"
    t.integer  "property_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_properties", ["product_id"], :name => "index_product_properties_on_product_id"

  create_table "product_scopes", :force => true do |t|
    t.integer "product_group_id"
    t.string  "name"
    t.text    "arguments"
  end

  add_index "product_scopes", ["name"], :name => "index_product_scopes_on_name"
  add_index "product_scopes", ["product_group_id"], :name => "index_product_scopes_on_product_group_id"

  create_table "products", :force => true do |t|
    t.string   "name",                 :default => "", :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.datetime "available_on"
    t.integer  "tax_category_id"
    t.integer  "shipping_category_id"
    t.datetime "deleted_at"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.integer  "count_on_hand",        :default => 0,  :null => false
  end

  add_index "products", ["available_on"], :name => "index_products_on_available_on"
  add_index "products", ["deleted_at"], :name => "index_products_on_deleted_at"
  add_index "products", ["name"], :name => "index_products_on_name"
  add_index "products", ["permalink"], :name => "index_products_on_permalink"

  create_table "products_taxons", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "taxon_id"
  end

  add_index "products_taxons", ["product_id"], :name => "index_products_taxons_on_product_id"
  add_index "products_taxons", ["taxon_id"], :name => "index_products_taxons_on_taxon_id"

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "presentation", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "property_id"
  end

  create_table "prototypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "return_authorizations", :force => true do |t|
    t.string   "number"
    t.decimal  "amount",     :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "order_id"
    t.text     "reason"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id", :limit => 8
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shares", :force => true do |t|
    t.integer  "user_id",         :limit => 8, :null => false
    t.integer  "subject_id",      :limit => 8, :null => false
    t.string   "subject_type",                 :null => false
    t.string   "subject_url",                  :null => false
    t.string   "service",                      :null => false
    t.text     "recipients",                   :null => false
    t.text     "message"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upload_batch_id", :limit => 8
    t.string   "share_type"
  end

  add_index "shares", ["subject_id"], :name => "index_shares_on_subject_id"
  add_index "shares", ["user_id", "subject_id"], :name => "user_id_subject_id_index"
  add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

  create_table "shipments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.string   "tracking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number"
    t.decimal  "cost",               :precision => 8, :scale => 2
    t.datetime "shipped_at"
    t.integer  "address_id"
    t.string   "state"
  end

  add_index "shipments", ["number"], :name => "index_shipments_on_number"

  create_table "shipping_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_methods", :force => true do |t|
    t.integer  "zone_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_on"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id",   :limit => 8,                 :null => false
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "state_events", :force => true do |t|
    t.integer  "stateful_id"
    t.integer  "user_id",        :limit => 8
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "previous_state"
    t.string   "stateful_type"
    t.string   "next_state"
  end

  create_table "states", :force => true do |t|
    t.string  "name"
    t.string  "abbr"
    t.integer "country_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.string   "email",                                            :null => false
    t.string   "unsubscribe_token",                                :null => false
    t.integer  "user_id",              :limit => 8
    t.integer  "want_marketing_email",              :default => 1
    t.integer  "want_news_email",                   :default => 1
    t.integer  "want_social_email",                 :default => 1
    t.integer  "want_status_email",                 :default => 1
    t.integer  "want_invites_email",                :default => 1
    t.datetime "last_email_at"
    t.string   "last_email_kind"
    t.string   "last_email_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["email"], :name => "index_subscriptions_on_email"
  add_index "subscriptions", ["unsubscribe_token"], :name => "index_subscriptions_on_unsubscribe_token"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "system_settings", :force => true do |t|
    t.string   "name"
    t.string   "label"
    t.string   "data_type"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  add_index "system_settings", ["name"], :name => "index_system_settings_on_name"

  create_table "tax_categories", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",  :default => false
  end

  create_table "tax_rates", :force => true do |t|
    t.integer  "zone_id"
    t.decimal  "amount",          :precision => 8, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_category_id"
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxons", :force => true do |t|
    t.integer  "taxonomy_id",                      :null => false
    t.integer  "parent_id"
    t.integer  "position",          :default => 0
    t.string   "name",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "description"
  end

  add_index "taxons", ["parent_id"], :name => "index_taxons_on_parent_id"
  add_index "taxons", ["permalink"], :name => "index_taxons_on_permalink"
  add_index "taxons", ["taxonomy_id"], :name => "index_taxons_on_taxonomy_id"

  create_table "trackers", :force => true do |t|
    t.string   "environment"
    t.string   "analytics_id"
    t.boolean  "active",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", :id => false, :force => true do |t|
    t.integer "user_id",            :limit => 8, :null => false
    t.integer "tracked_id",         :limit => 8, :null => false
    t.integer "track_type",         :limit => 1, :null => false
    t.integer "user_last_touch_at"
  end

  add_index "tracks", ["user_id", "tracked_id", "track_type"], :name => "index_tracks_on_user_id_and_tracked_id_and_track_type", :unique => true
  add_index "tracks", ["user_last_touch_at"], :name => "index_tracks_on_user_last_touch_at"

  create_table "upload_batches", :force => true do |t|
    t.integer  "album_id",                  :limit => 8,                                    :null => false
    t.integer  "user_id",                   :limit => 8,                                    :null => false
    t.string   "state",                                  :default => "open"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "custom_order_offset",                    :default => 0.0
    t.datetime "open_activity_at",                       :default => '1970-01-01 00:00:00'
    t.integer  "lock_version",                           :default => 0
    t.datetime "original_batch_created_at",              :default => '1970-01-01 00:00:00'
  end

  add_index "upload_batches", ["album_id"], :name => "index_upload_batches_on_album_id"
  add_index "upload_batches", ["created_at"], :name => "index_upload_batches_on_created_at"
  add_index "upload_batches", ["open_activity_at", "state"], :name => "index_upload_batches_on_open_activity_at_and_state"
  add_index "upload_batches", ["state"], :name => "index_upload_batches_on_state"
  add_index "upload_batches", ["updated_at", "state"], :name => "index_upload_batches_on_updated_at_and_state"
  add_index "upload_batches", ["user_id"], :name => "index_upload_batches_on_user_id"

  create_table "user_preferences", :force => true do |t|
    t.integer "user_id",         :limit => 8,                    :null => false
    t.boolean "tweet_likes",                  :default => false
    t.boolean "facebook_likes",               :default => false
    t.boolean "asktopost_likes",              :default => true
  end

  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                    :null => false
    t.string   "username"
    t.string   "first_name",                               :null => false
    t.string   "last_name"
    t.string   "style",               :default => "white", :null => false
    t.string   "crypted_password",                         :null => false
    t.string   "password_salt",                            :null => false
    t.string   "persistence_token",                        :null => false
    t.string   "single_access_token",                      :null => false
    t.string   "perishable_token",                         :null => false
    t.integer  "failed_login_count",  :default => 0,       :null => false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",              :default => true,    :null => false
    t.boolean  "approved",            :default => true,    :null => false
    t.boolean  "automatic",           :default => false
    t.integer  "login_count",         :default => 0
    t.datetime "last_request_at"
    t.integer  "cohort"
    t.integer  "ship_address_id"
    t.integer  "bill_address_id"
  end

  add_index "users", ["cohort"], :name => "index_users_on_cohort"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "variants", :force => true do |t|
    t.integer  "product_id"
    t.string   "sku",                                         :default => "",    :null => false
    t.decimal  "price",         :precision => 8, :scale => 2,                    :null => false
    t.decimal  "weight",        :precision => 8, :scale => 2
    t.decimal  "height",        :precision => 8, :scale => 2
    t.decimal  "width",         :precision => 8, :scale => 2
    t.decimal  "depth",         :precision => 8, :scale => 2
    t.datetime "deleted_at"
    t.boolean  "is_master",                                   :default => false
    t.integer  "count_on_hand",                               :default => 0,     :null => false
    t.decimal  "cost_price",    :precision => 8, :scale => 2
    t.integer  "position"
  end

  add_index "variants", ["product_id"], :name => "index_variants_on_product_id"

  create_table "zone_members", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "zoneable_id"
    t.string   "zoneable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
