class Admin::HomepageController < Admin::AdminController
  def show
       @page = 'homepage'
       @settings = []
       @settings << SystemSetting.find_by_name!('homepage_deploy_tag')
  end

  def update
    begin
      if params[:homepage_deploy_tag]
        SystemSetting[:homepage_deploy_tag] = params[:homepage_deploy_tag]
        HomepageManager.deploy(SystemSetting[:homepage_deploy_tag])
      end
      flash[:notice]="Homepage Deployed!"
    rescue Exception => e
      flash[:error]= e.message
    end
    redirect_to :back
  end
end