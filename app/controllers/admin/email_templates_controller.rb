#
#  Copyright 2011, ZangZing, LLC www.zangzing.com
#

class Admin::EmailTemplatesController < Admin::AdminController

  helper :all
  before_filter :load_emails, :only => [:new, :create, :edit, :update]
  before_filter :fetch_email_template, :only => [:destroy, :edit, :update]

  def new
    @email_template = EmailTemplate.new()
  end

  def create
    @email_template= EmailTemplate.new(params[:email_template])
    if @email_template.save
      flash[:notice]="Template #{@email_template.name} has been created"
      redirect_to email_templates_path()
    else
      render :new
    end
  end

  def index
    @email_templates = EmailTemplate.all
  end

  def edit
  end

  def update
    if @email_template.update_attributes(params[:email_template])
      flash[:notice]="Template '#{@email_template.name}' has been updated"
    end
    render :edit
  end

  def destroy
    if @email_template.destroy
      flash[:notice]="Template '#{@email_template.name}' has been deleted"
      redirect_to email_templates_path()
    else
      render :edit
    end
  end

  def test
    if params[:id] && params[:id]=='all'
      i = 0
      EmailTemplate.all.each do |et|
        begin
          @message = send('test_'+et.email.name, et.id)
          @message[:to]=params[:target_address] unless params[:target_address].blank?
          @message.deliver
          i += 1
        rescue SubscriptionsException => e
          flash[:error]= "#{i} messages sent but there was an error on #{et.name} "+e.message
          redirect_to :back and return
        rescue Exception => e
          flash[:error]="#{i} messages sent but unable to test template #{et.name} because: #{(e.message && e.message.length >0 ? e.message : e)}."
          redirect_to :back and return
        end
      end
      flash[:notice]="#{i} test messages sent to #{params[:target_address]}."
      redirect_to :back and return
    else
      begin
        @template = EmailTemplate.find(params[:id])
        @message = send('test_'+@template.email.name, @template.id)
        if params[:onscreen]
          render :layout => false
        else
          @message[:to]=params[:target_address] unless params[:target_address].blank?
          @message.deliver
          flash[:notice]="Test #{@template.email.name} message sent to #{@message[:to]}."
          redirect_to :back
        end
      rescue SubscriptionsException => e
        flash[:error]= e.message
        redirect_to :back
      rescue Exception => e
        flash[:error]="Unable to test template because: #{(e.message && e.message.length >0 ? e.message : e)}."
        redirect_to :back
      end
    end

  end

private

  def load_emails
    @emails = Email.all
  end

  def fetch_email_template
    @email_template = EmailTemplate.find(params[:id])
  end


  def test_photos_ready(template_id)
    Notifier.photos_ready(upload_batch.id, template_id)
  end

  def test_password_reset(template_id)
    Notifier.password_reset(recipient.id, template_id)
  end

  def test_album_liked(template_id)
    Notifier.album_liked(sender.id, album.id, template_id)
  end

  def test_photo_liked(template_id)
    Notifier.photo_liked(sender.id, photo.id, recipient.id, template_id)
  end

  def test_user_liked(template_id)
    Notifier.user_liked(sender.id, recipient.id, template_id)
  end

  def test_contribution_error(template_id)
    Notifier.contribution_error(recipient.email, template_id)
  end

  def test_album_shared(template_id)
    Notifier.album_shared(sender.id, user_or_not_user_email_address, album.id, message, template_id)
  end

  def test_album_updated(template_id)
    Notifier.album_updated(sender.id, recipient.id, album.id, upload_batch.id, template_id)
  end

  def test_contributor_added(template_id)
    Notifier.contributor_added(album.id, user_or_not_user_email_address, message, template_id)
  end

  def test_welcome(template_id)
    Notifier.welcome(recipient.id, template_id)
  end

  def test_photo_shared(template_id)
    Notifier.photo_shared(sender.id, user_or_not_user_email_address, photo.id, message, template_id)
  end

  def test_beta_invite(template_id)
    Notifier.beta_invite(recipient.email, template_id)
  end

  def test_photo_comment(template_id)
    Notifier.photo_comment(sender.id, recipient.id, comment.id, template_id)
  end

  def test_order_confirmed(template_id)
    Notifier.order_confirmed(order.id, template_id)
  end

  def test_order_cancelled(template_id)
    Notifier.order_cancelled(order.id, template_id)
  end

  def test_order_shipped(template_id)
    Notifier.order_shipped(order.shipment.id, template_id)
  end

  def test_request_access(template_id)
    Notifier.request_access(sender.id, album.id, message, template_id)
  end

  def test_request_contributor(template_id)
    Notifier.request_contributor(sender.id, album.id, message, template_id)
  end

  def test_invite_to_join(template_id)
    invitation = Invitation.find_or_create_invitation_for_email(sender, 'test@test.zangzing.com')
    Notifier.invite_to_join(sender.id, user_or_not_user_email_address, invitation.tracked_link.url, template_id)
  end

  def test_joined_from_invite(template_id)
    invitation = Invitation.find_or_create_invitation_for_email(sender, 'test@test.zangzing.com')
    invitation = Invitation.process_invitations_for_new_user(current_user, invitation.tracked_link.tracking_token)
    Notifier.joined_from_invite(invitation.id, true, template_id)
  end

  def user_or_not_user_email_address
    if rand(2) <= 0
      current_user.email
    else
      "not-a-user-for-emailsample@bucket.zangzing.com"
    end
  end

  def recipient
    current_user
  end

  def sender
    User.find_by_username!('zangzing')
  end

  def comment
    commentable = Commentable.find_or_create_by_photo_id(photo.id)

    if commentable.comments.count == 0
      comment = Comment.new
      comment.user = current_user
      comment.text = 'this is a comment'
      commentable.comments << comment
    else
      comment = commentable.comments.first
    end

    comment
  end

  def album
    album = nil
    while album.nil? || album.cover.nil?
      album = current_user.albums[rand(current_user.albums.count)]
    end
    album
  end

  def photo
    photo = nil
    while photo.nil?
      photo = album.photos[rand(album.photos.count)]
    end
    photo
  end

  def upload_batch
    begin
      @ub = album.upload_batches[rand(album.upload_batches.count)]
    end while @ub.nil? || @ub.photos.count <=0
    @ub
  end

  def message
    if rand(4) >= 2
      "This message is automatically generated for test emails, Its mimics a custom message written by a user. "+
          "It will be included randomly so you may or may not see it. Line break here ==>\n"+
          "The following symbols are part of the test. It contains backslash n line breaks for testing "+
          "<This is full & of HTML symbols <which></should> Line Break here ==>\n"+
          "&Be<> escaped> END OF TEST MESSAGE"
    else
      ""
    end
  end

  def order
    orders = Order.by_state('shipped')
    order_count = orders.count
    orders[rand(order_count)]
  end

end
