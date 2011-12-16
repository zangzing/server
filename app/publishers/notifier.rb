class Notifier < ActionMailer::Base
  include ZZ::Mailer
  include PrettyUrlHelper
  include TrackingHelper
  add_template_helper(TrackingHelper)
  add_template_helper(PrettyUrlHelper)

  include OrderNotifier


  def photos_ready( batch_id, template_id = nil )
    @batch   = UploadBatch.find( batch_id )
    @user    = @batch.user
    @album   = @batch.album
    @photos  = @batch.photos
    @recipient = @user
    @album_url = album_pretty_url( @album )
    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    create_message( __method__, template_id, @recipient,  { :user_id => @user.id })
  end




  def password_reset(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @password_reset_url = edit_password_reset_url(@user.perishable_token)
    # Add a header for fast delivery
    sendgrid_headers.merge!( {'bypass_list_management' => { 'enable' => 1 }} )

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def album_liked( user_id, album_id,  template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def photo_liked( user_id, photo_id, recipient_id, template_id = nil )
    @user      = User.find( user_id )
    @photo     = Photo.find( photo_id )
    @recipient = User.find( recipient_id )

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def user_liked( user_id, liked_user_id,  template_id = nil )
    @user      = User.find( user_id )
    @recipient = User.find( liked_user_id )

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def contribution_error( to_address, template_id = nil)
    @recipient = User.find_by_email( to_address )

    create_message(  __method__, template_id, ( @recipient? @recipient : to_address ), { :to => to_address })
  end




  def photo_shared(from_user_id,to_address,photo_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @photo = Photo.find(photo_id)
    @message = message
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )
    @destination_link = destination_link( @recipient, photo_pretty_url( @photo ) )

    create_message(  __method__, template_id, @recipient, { :to => to_address })
  end




  def beta_invite(to_address,  template_id = nil)
    create_message(  __method__, template_id,  to_address, { :to => to_address })
  end




  def album_shared(from_user_id,to_address,album_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )
    @destination_link = destination_link(  @recipient, album_pretty_url( @album ) )


    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def album_updated( from_user_id, to_address_or_id, album_id, batch_id,  template_id = nil )
    @album     = Album.find( album_id )
    @user      = User.find( from_user_id )
    @batch     = UploadBatch.find( batch_id )
    @photos    = @batch.photos
    # if to_address_or_id is an email, we already know that the email is not a user yet.
    rcp_user = User.find_by_id( to_address_or_id )
    @recipient = ( rcp_user ? rcp_user : to_address_or_id )
    @destination_link = destination_link( @recipient, album_pretty_url( @album ) )

    create_message(  __method__, template_id,  @recipient, { :user_id => @user.id } )
  end




  def contributor_added(album_id, to_address, message, template_id = nil )
    @album = Album.find(album_id)
    @user = @album.user
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )
    @message = message
    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s
    @destination_link = destination_link( @recipient, album_pretty_url( @album ) )

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id })
  end




  def welcome(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user

    create_message(  __method__, template_id, @recipient,   { :user_id => @user.id })
  end


  def request_access( user_id, album_id,  message,template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user
    @message   = message

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def request_contributor( user_id, album_id,  message,template_id = nil )
      @user      = User.find( user_id )
      @album     = Album.find( album_id )
      @recipient = @album.user
      @message   = message

      create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end



  def activation_instructions(user_id)
    user = User.find(user_id)
    @account_activation_url = activate_url(user.perishable_token)
    logger.info "Mailed activation_instructions: #{user.email}"
    mail( :to      => user.email,
          :subject => "Account Activation Instructions for your ZangZing Account" )
  end




  def test_email( to )
    logger.info "Mailed test_email: #{to}"
    mail( :to      => to,
          :subject => "Test from ZangZing #{Rails.env.capitalize} Environment") do |format|
      format.text { render :inline => " <%=message.to.to_s%> This is the message body of the test" }
    end
  end

  def photo_comment(comment_added_by_user_id, send_notification_to_user_id_or_address, comment_id, template_id = nil)
    @user = User.find(comment_added_by_user_id)
    @comment = Comment.find(comment_id)
    @photo = @comment.commentable.subject
    # if send_notification_to_user_id_or_address is an email, we already know that the email is not a user yet.
    rcp_user = User.find_by_id( send_notification_to_user_id_or_address )
    @recipient = ( rcp_user ? rcp_user : send_notification_to_user_id_or_address )
    create_message( __method__, template_id,  @recipient, { :user_id => @user.id } )
  end
end

