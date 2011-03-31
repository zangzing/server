class UpdateShares < ActiveRecord::Migration
  def self.up
    create_table     :shares, :force => true do |t|
          t.column   :user_id,     :bigint, :null => false
          t.column   :subject_id,   :bigint, :null => false
          t.string   :subject_type, :null => false
          t.string   :subject_url,  :null => false
          t.string   :service,      :null => false
          t.text     :recipients,    :null => false
          t.text     :message
          t.datetime :sent_at
          t.datetime :created_at
          t.datetime :updated_at
        end

        add_index "shares", ["subject_id"], :name => "index_shares_on_subject_id"
        add_index "shares", ["user_id", "subject_id"], :name => "user_id_subject_id_index"
        add_index "shares", ["user_id"], :name => "index_shares_on_user_id"
  end

  def self.down
        drop_table :shares
  end
end


