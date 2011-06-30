class Notifier < ActionMailer::Base
  add_template_helper(PrettyUrlHelper)
  include PrettyUrlHelper

  ActionMailer::Base.logger = Rails.logger
  default :charset => "utf-8"
  if Rails.env == 'production'
    default :from => '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    default :from => '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end

  def photos_ready( batch_id, template_id = nil )
    batch   = UploadBatch.find( batch_id )
    @user   = batch.user
    @album  = batch.album
    @photos = batch.photos
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

    @recipient.subscriptions.wants_email!( Email::STATUS, __method__ )
    create_message( binding(), __method__, template_id, @recipient,  { :user_id => @user.id })
  end

  def password_reset(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @password_reset_url = edit_password_reset_url(@user.perishable_token)

    @recipient.subscriptions.wants_email!( Email::TRANSACTIONAL, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def album_liked( user_id, album_id,  template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user

    @recipient.subscriptions.wants_email!( Email::SOCIAL, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def photo_liked( user_id, photo_id, recipient_id, template_id = nil )
    @user      = User.find( user_id )
    @photo     = Photo.find( photo_id )
    @recipient = User.find( recipient_id )

    @recipient.subscriptions.wants_email!( Email::SOCIAL, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def user_liked( user_id, liked_user_id,  template_id = nil )
    @user      = User.find( user_id )
    @recipient = User.find( liked_user_id )

    @recipient.subscriptions.wants_email!( Email::SOCIAL, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def contribution_error( to_address, template_id = nil)
    @recipient = User.find_by_email( to_address )

    Subscriptions.wants_email!( to_address, Email::TRANSACTIONAL, __method__ )
    create_message( binding(), __method__, template_id, ( @recipient? @recipient : to_address ), { :to => to_address })
  end

  def photo_shared(from_user_id,to_address,photo_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @photo = Photo.find(photo_id)
    @message = message
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )

    set_destination_link( @recipient, photo_pretty_url( @photo ) )
    Subscriptions.wants_email!( to_address, Email::INVITES, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :to => to_address })
  end

  def beta_invite(to_address,  template_id = nil)
    Subscriptions.wants_email!( to_address, Email::TRANSACTIONAL, __method__ )
    create_message( binding(), __method__, template_id,  to_address, { :to => to_address })
  end

  def album_shared(from_user_id,to_address,album_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )
    
    set_destination_link(  @recipient, album_pretty_url( @album ) )
    Subscriptions.wants_email!( to_address, Email::INVITES, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def album_updated( from_user_id, to_address_or_id, album_id, batch_id,  template_id = nil )
    @album     = Album.find( album_id )
    @user      = User.find( from_user_id )
    @photos = UploadBatch.find( batch_id ).photos
    # if to_address_or_id is an email, we already know that the email is not a user yet.
    rcp_user = User.find_by_id( to_address_or_id )
    @recipient = ( rcp_user ? rcp_user : to_address_or_id )

    set_destination_link( @recipient, album_pretty_url( @album ) )
    Subscriptions.wants_email!( @recipient, Email::SOCIAL, __method__ )
    create_message( binding(), __method__, template_id,  @recipient, { :user_id => @user.id } )
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

    set_destination_link( @recipient, album_pretty_url( @album ) )
    Subscriptions.wants_email!( to_address, Email::INVITES, __method__ )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id })
  end

  def welcome(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @recipient.subscriptions.wants_email!( Email::TRANSACTIONAL, __method__ )
    create_message( binding(), __method__, template_id, @recipient,   { :user_id => @user.id })
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

  private
  # This the the method that puts together the message using the class vars set in
  # the message environment
  #
  #
  # * <tt>binding</tt> - The binding for all vars set for the message (usually just binding() )
  # * <tt>template_name</tt> - The name of the production template you want to use. It
  #   will not be used if template_id is present
  # * <tt>template_id </tt> - The id of the specific template you want to use. Used for testing templates that are not
  #   in production yet.
  # * <tt>recipient</tt> - The recipient for the message, it maybe a User in which case we call
  #   recipient.formatted_email or a string with the email address
  # * <tt>event_data_hash</tt> - A hash of information that will be sent with to ZZA as xdata


  def create_message( binding, template_name, template_id=nil, recipient=nil, zza_xdata=nil )

    # Load the appropriate template
    if template_id
      @template  = EmailTemplate.find( template_id )
    else
      @template = Email.find_by_name!( template_name ).production_template
    end

    #Process recipient 
    if recipient.is_a?(User)
      encoded_name = Mail::Encodings::decode_encode( recipient.name, :encode )
      @to_address  = Mail::Address.new("\"#{encoded_name}\" <#{recipient.email}>")
    else
      @to_address = Mail::Address.new( recipient.to_slug.to_ascii.to_s )
    end

    @unsubscribe_url   = unsubscribe_url(  @unsubscribe_token = Subscriptions.unsubscribe_token( recipient ) )
    @unsubscribe_email = Mail::Address.new( "#{@unsubscribe_token}@unsubscribe.#{Server::Application.config.album_email_host}" ).address
    headers @template.sendgrid_category_header     #set sendgrid category header
    headers['X-ZZSubscription-Id'] = @unsubscribe_token
    headers['List-Unsubscribe'] = "<mailto:#{@unsubscribe_email}>,<#{@unsubscribe_url}>,"

    #send zza event
    ZZ::ZZA.new.track_event("#{template.category}.send", zza_xdata )
    mail( :to       => @to_address.format,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
     logger.info "MAIL SENT:  #{template_name} to: #{@to_address} triggered by "+
     "#{( @user? @user.username : 'notifications system')}"
  end

  def set_destination_link( recipient, destination_url )
    if recipient.is_a?(User)
      @destination_link = "#{signin_url}?return_to=#{destination_url}&email=#{recipient.username}"
    else
      @destination_link = "#{join_url}?return_to=#{destination_url}&email=#{recipient}"
    end
  end
end

