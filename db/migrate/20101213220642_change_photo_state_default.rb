class ChangePhotoStateDefault < ActiveRecord::Migration
  def self.up
    change_column :photos, :state,  :string,  :default => "assigned"
  end

  def self.down
    change_column :photos, :state,  :string,  :default => "new"
  end
end
