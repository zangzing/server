#
#  Copyright 2011, ZangZing, LLC www.zangzing.com
#

class Admin::EmailTemplatesController < Admin::AdminController

  helper :all

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

  def test
    begin
      @template = EmailTemplate.find( params[:id] )
      @message = send( 'test_'+@template.email.name, @template.id )
      if params[:onscreen]
        render :layout => false
      else
        @message.deliver
        flash[:notice]="Test #{@template.email.name} message sent to #{current_user.email}."
        redirect_to :back
      end
    rescue SubscriptionsException => e
      flash[:error]= e.message
      redirect_to :back
    rescue Exception => e
      flash[:error]="Unable to test template because: #{(e.message && e.message.length >0 ? e.message : e )}."
      redirect_to :back
    end
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


  def test_photos_ready( template_id )
    Notifier.photos_ready( upload_batch.id, template_id )
  end

  def test_password_reset( template_id )
    Notifier.password_reset( recipient.id, template_id )
  end

  def test_album_liked(  template_id )
    Notifier.album_liked( sender.id, album.id, template_id)
  end

  def test_photo_liked(  template_id )
    Notifier.photo_liked( sender.id, photo.id, recipient.id, template_id)
  end

  def test_user_liked(  template_id )
    Notifier.user_liked( sender.id, recipient.id, template_id)
  end

  def test_contribution_error(  template_id )
    Notifier.contribution_error( recipient.email, template_id)
  end

  def test_album_shared( template_id )
    Notifier.album_shared( sender.id, recipient.email, album.id, message, template_id)
  end

  def test_album_updated( template_id )
    Notifier.album_updated( sender.id,  recipient.id, album.id, upload_batch.id, template_id)
  end

  def test_contributor_added( template_id )
    Notifier.contributor_added( album.id, recipient.email, message, template_id)
  end

  def test_welcome( template_id )
    Notifier.welcome( recipient.id, template_id)
  end

  def test_photo_shared( template_id )
    Notifier.photo_shared( sender.id, recipient.email, photo.id, message, template_id)
  end

  def test_beta_invite( template_id )
    Notifier.beta_invite( recipient.email, template_id)
  end



  def test_photo_comment( template_id )
    Notifier.photo_shared( sender.id, recipient.id, comment.id, template_id)
  end


  def recipient
    current_user
  end

  def sender
    User.find_by_username!('zangzing')
  end

  def comment
    commentable = Commentable.find_or_create_by_photo_id(photo.id)
    comment = commentable.comments.create({:text => 'this is a comment'})
    comment
  end

  def album
    album = nil
    while album.nil? || album.cover.nil?
      album = current_user.albums[ rand( current_user.albums.count) ]
    end
    album
  end

  def photo
    album.photos[ rand( album.photos.count )]
  end

  def upload_batch
    begin
      @ub = album.upload_batches[ rand( album.upload_batches.count) ]
    end while @ub.nil? || @ub.photos.count <=0
    @ub
  end

  def message
    if rand(2) == 1
      "This message is automatically generated for test emails, Its mimics a custom message written by a user. "+
          "It will be included randomly so you may or may not see it. The following symbols are part of the test  "+
          "<This is full & of HTML symbols <which></should> &Be<> escaped> END OF TEST MESSAGE"
    else
      ""
    end
  end

end
