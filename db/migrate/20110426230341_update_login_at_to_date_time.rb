class UpdateLoginAtToDateTime < ActiveRecord::Migration
  def self.up
    change_column :users,   :current_login_at, :datetime
    change_column :users,   :last_login_at,    :datetime
  end

  def self.down
    change_column :users,   :current_login_at, :date
    change_column :users,   :last_login_at,    :date
  end
end
