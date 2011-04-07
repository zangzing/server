class SystemSettings < ActiveRecord::Migration
  def self.up
     create_table :system_settings, :force => true do |t|
      t.string    :name,  :null => :false
      t.string    :label, :null => :false
      t.string    :data_type,  :null => :false
      t.string    :value
      t.timestamps
     end
     add_index :system_settings, :name
     SystemSetting.create( :name  => :new_users_allowed,
                           :label => "Allow this many new users (-1 for unlimited)",
                           :data_type  => 'integer',
                           :value => -1)
     SystemSetting.create( :name  => :always_allow_beta_listers,
                           :label => "Always allow beta-listers to sign up",
                           :data_type  => 'boolean',
                           :value => 1)
     SystemSetting.create( :name  => :allow_sharers,
                           :label => 'Allow "shared" users to sign up',
                           :data_type  => 'boolean',
                           :value => 0)
     SystemSetting.create( :name  => :allow_everyone,
                           :label => 'Allow anyone to sign up',
                           :data_type  => 'boolean',
                           :value => 0)
  end

  def self.down
      drop_table :system_settings
  end
end
