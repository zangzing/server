class AddSignupControlSetting < ActiveRecord::Migration
  def self.up
    SystemSetting.create( :name  => :signup_control,
                           :label => 'Turn ON Signup Control (when off anyone can signup)',
                           :data_type  => 'boolean',
                           :value => 0)
    everyone = SystemSetting.find_by_name('allow_everyone')
    everyone.destroy unless everyone.nil?
  end

  def self.down
  end
end
