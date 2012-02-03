class AddBonusForJoinFieldToTrackedLinks < ActiveRecord::Migration
  def self.up
    add_column :tracked_links, :credit_for_join, :boolean, :default=>true
    add_column :tracked_links, :last_referrer, :string
  end

  def self.down
    remove_column :tracked_links, :credit_for_join
    remove_column :tracked_links, :last_referrer
  end
end
