
class Admin::ChimpcampaignsController < Admin::AdminController
  # To change this template use File | Settings | File Templates.


  def index
    load_info
  end

  def edit
    load_info
    @campaign = @campaigns.find{ |c| c['id'].to_f == params['id'].to_f }
  end

  def update
    begin
      @campaign = params['camp']
      ZZ::MailChimp.update_trans_campaign( @campaign['title'],
                                           @campaign['list_id'],
                                           @campaign['template_id'],
                                           @campaign['subject'],
                                           @campaign['from_email'],
                                           @campaign['from_name'] )
    rescue ZZ::MailChimp::Error => e
      flash[:error] = e.message
      load_info
      render 'index' and return
    end
    flash[:info] = "Campaign Created!"
    redirect_to :action => "index"
  end

  def new
    load_info
    @campaign = Hash.new()
  end

  def create
    begin
      @campaign = params['camp']
      ZZ::MailChimp.create_transactional_campaign( @campaign['title'],
                                           @campaign['list_id'],
                                           @campaign['template_id'],
                                           @campaign['subject'],
                                           @campaign['from_email'],
                                           @campaign['from_name'] )
    rescue ZZ::MailChimp::Error => e
      flash[:error] = e.message
      load_info
      render 'index' and return
    end
    flash[:info] = "Campaign Created!"
    redirect_to :action => "index"
  end

  def delete
    begin
      ZZ::MailChimp.delete_campaign( params['id'] )
    rescue ZZ::MailChimp::Error => e
      flash[:error] = e.message
    else
      flash[:info] = "Campaign Deleted!"
    end
    redirect_to :action => "index"
  end

  private
   def load_info

    @lists     = ZZ::MailChimp.get_lists
    @templates = ZZ::MailChimp.get_templates
    @campaigns = ZZ::MailChimp.get_transactional_campaigns

    @campaigns.each do |campaign|
          template = @templates.find{ |t| t['id'].to_s == campaign['template_id'].to_s }
          campaign['template_name'] = template['name'] unless template.nil?
          list = @lists.find{ |l| l['id'].to_s == campaign['list_id'].to_s}
          campaign['list_name']=list['name'] unless list.nil?
    end



  end

end