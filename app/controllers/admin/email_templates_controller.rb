class Admin::EmailTemplatesController < ApplicationController

  layout false

  def new
    load_info
    @email_template = EmailTemplate.new()
  end

  def create
    @email_template=  EmailTemplate.new( params[:email_template ])
    if @email_template.save
      redirect_to email_templates_path()
    else
      load_info
      render :new
    end
  end

  def index
    load_info
    @email_templates = EmailTemplate.find(:all)
  end

  def show
  end

  def edit
    fetch_email_template
    load_info
  end

  def update
    fetch_email_template
    if @email_template.update_attributes(params[:email_template])
       redirect_to email_templates_path()
    else
      load_info
      render :edit
    end
  end

  def destroy
    fetch_email_template
    if @email_template.destroy
       redirect_to email_templates_path()
    else
      load_info
      render :edit
    end
  end

  def reload
    fetch_email_template
    @email_template.reload_mc_content
    redirect_to :action => :index
  end




private
  def load_info
    mc = Hominid::API.new(MAILCHIMP_API_KEYS[:api_key])
    @campaigns = mc.find_campaigns_by_type( 'regular' )
    @campaign_options = []
    @campaigns.each { |c|   @campaign_options << [ c['title'], "#{c['id']}"] }
  end

  def fetch_email_template
    @email_template = EmailTemplate.find( params[:id])
  end

  def test_album_shared_with_you( destination_email)
    @user = User.find(:all).first
    @message = "This is a message to you you you"
    @album =Album.find(:all).first
    render :inline => @email_template.html_content and return
end


end
