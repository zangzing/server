class AddSystemWideMessageSettings < ActiveRecord::Migration
  def self.up
      SystemSetting.create( :name  => :system_message_text,
                           :label => 'Message',
                           :description => 'A Systemt Wide Message to be displayed to all active users at the top of the ZangZing app',
                           :data_type  => 'string',
                           :value => 'ZangZing will have a brief interruption of service for maintenance at 5:00AM PST Tomorrow')
     SystemSetting.create( :name  => :system_message_enabled,
                           :label => 'Enabled',
                           :description => 'The system message will only be displayed if its enabled',
                           :data_type  => 'boolean',
                           :value => false )
     SystemSetting.create( :name  => :system_message_style,
                           :label => 'Style',
                           :description => 'The decoration style to be used when displaying the message',
                           :data_type  => 'string',
                           :value => 'Maintenance')
  end

  def self.down
  end
end
