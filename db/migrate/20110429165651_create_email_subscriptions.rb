class CreateEmailSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions, :force => true do |t|
      t.column :email,                     :string,   :null => false
      t.column :unsubscribe_token,         :string,   :null => false
      t.column :user_id,                   :bigint

      t.column :want_marketing_email,      :integer,  :default => 1
      t.column :want_news_email,           :integer,  :default => 1
      t.column :want_social_email,         :integer,  :default => 1
      t.column :want_status_email,         :integer,  :default => 1
      t.column :want_invites_email,        :integer,  :default => 1
      t.column :last_email_at,             :datetime
      t.column :last_email_kind,           :datetime
      t.column :last_email_name,           :datetime
      
      t.timestamps
      end

    add_index :subscriptions, :email
    add_index :subscriptions, :unsubscribe_token
    add_index :subscriptions, :user_id

    say_with_time "Creating Subscriptions Records for all users..." do
      Subscriptions.reset_column_information
      User.all.each do |u|
        u.create_subscriptions
      end
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
