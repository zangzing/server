# Added a style field to keep track of which style the user wants to use for the application
# the default style is the white style and possible values are
# WHITE or GRAY

class AddStylePreferenceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :style, :string, :default => 'white'
  end

  def self.down
    remove_column :users, :style
  end
end
