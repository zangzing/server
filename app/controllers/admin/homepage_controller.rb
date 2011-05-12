class Admin::HomepageController < Admin::AdminController
  def show
       @page = 'homepage'
       @settings = []
       @settings << SystemSetting.find_by_name!('homepage_deploy_tag')
  end

  def update
    @previous_tag = SystemSetting[:homepage_deploy_tag]
    begin
      if params[:homepage_deploy_tag]
        HomepageManager.deploy(params[:homepage_deploy_tag])
        SystemSetting[:homepage_deploy_tag] = params[:homepage_deploy_tag]
        flash[:notice]="Homepage Deployed!"
      end
    rescue Exception => e
      SystemSetting[:homepage_deploy_tag] = @previous_tag
      flash[:error]= e.message
    end
    redirect_to :back
  end
end