class Admin::SystemSettingsController < Admin::AdminController
  def show
    @page = 'settings'
    @settings = SystemSetting.all()
  end

  def update
    @settings =  SystemSetting.all()
    @settings.each do |setting|
      if params[setting.name]
        setting.update_attribute(:value, params[setting.name])
      end
    end
    redirect_to system_settings_path
  end
end