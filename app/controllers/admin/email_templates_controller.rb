class Admin::EmailTemplatesController < Admin::AdminController

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
       redirect_to :back
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
    redirect_to :back
  end




private
  def load_info
    gb = Gibbon::API.new(MAILCHIMP_API_KEYS[:api_key])

    @campaigns = gb.campaigns('filters' => {'folder_id' => "21177"})['data']
    @campaign_options = []
    @campaigns.each { |c|   @campaign_options << [ c['title'], "#{c['id']}"] }
    
    @emails = Email.find(:all)
    @email_options = []
    @emails.each { |e|   @email_options << [ e.name, "#{e.id}"] }
  end

  def fetch_email_template
    @email_template = EmailTemplate.find( params[:id])
  end
end
