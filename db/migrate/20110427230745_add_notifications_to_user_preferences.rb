class AddNotificationsToUserPreferences < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :email,                     :string,   :null => false
    add_column :user_preferences, :want_marketing_email,      :integer,  :default => 1
    add_column :user_preferences, :want_news_email,           :integer,  :default => 1
    add_column :user_preferences, :want_social_email,         :integer,  :default => 1
    add_column :user_preferences, :want_status_email,         :integer,  :default => 1
    add_column :user_preferences, :want_invites_email,        :integer,  :default => 1
    add_column :user_preferences, :unsubscribe_token,         :string,   :null => false
    add_column :user_preferences, :created_at,                :datetime
    add_column :user_preferences, :updated_at,                :datetime

    add_index :user_preferences, :email
    add_index :user_preferences, :unsubscribe_token
  end

  def self.down
  end
end
