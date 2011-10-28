class MarketingPrints < ActiveRecord::Migration
  def self.up
    User.reset_column_information
    user = User.new(:email => 'marketinguser@zangzing.com', :name => 'ZangZing Marketing', :username => 'zzmarketing',
            :password => 'x739iutp', :automatic => false)
    user.reset_perishable_token
    user.reset_single_access_token
    user.save!

    add_column :line_items, :hidden, :boolean, :default => false
  end

  def self.down
    user = User.find_by_username('zzmarketing')
    user.destroy

    remove_column :line_items, :hidden
  end
end

