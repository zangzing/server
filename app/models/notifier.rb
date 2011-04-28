class Notifier < ActionMailer::Base
  add_template_helper(PrettyUrlHelper)

  if Rails.env == 'production'
    default :from => '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    default :from => '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end

  def logger
    Rails.logger
  end


  def photos_ready( batch_id, template_id = nil )
    batch = UploadBatch.find( batch_id )
    @user = batch.user
    @recipient = @user
    @album = batch.album
    @album_url = album_url( @album )
    @photos = batch.photos

    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    create_message( binding(), __method__, template_id, @recipient,  { :user_id => @user.id })

#    #Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def password_reset(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @password_reset_url = edit_password_reset_url(@user.perishable_token)
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
    
#    Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail(  :to       => @recipient.formatted_email,
#           :from     => @template.formatted_from,
#           :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#           :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def album_liked( user_id, album_id,  template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
#   Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def photo_liked( user_id, photo_id,  template_id = nil )
    @user      = User.find( user_id )
    @photo     = Photo.find( photo_id )
    @recipient = @photo.user
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )
    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def user_liked( user_id, liked_user_id,  template_id = nil )
    @user      = User.find( user_id )
    @recipient = User.find( liked_user_id )
    create_message( binding(), __method__, template_id, @recipient, { :user_id => @user.id } )

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def contribution_error( to_address, template_id = nil)
        @recipient = User.find_by_email( to_address )
        @template = Email.find_by_name!( __method__ ).production_template
        @template  = EmailTemplate.find( template_id ) if template_id
        create_message( binding(), __method__, template_id, ( @recipient? @recipient : to_address ), { :to => to_address })

        # Load interpolate and setup values from template
#        headers @template.sendgrid_category_header
#        ZZ::ZZA.new.track_event("#{@template.category}.send", to_address)
#        binding = binding()
#        mail(   :to       => ( @recipient? @recipient.formatted_email : to_address ),
#                :from     => @template.formatted_from,
#                :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#                :subject  => ERB.new( @template.subject).result(binding)
#        ) do |format|
#          format.text { render :inline => @template.text_content }
#          format.html { render :inline => @template.html_content }
#        end
  end

  def photo_shared(from_user_id,to_address,photo_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @photo = Photo.find(photo_id)
    @message = message
    @recipient = User.find_by_email( to_address )
    create_message( binding(), __method__, template_id, ( @recipient? @recipient : to_address ), { :to => to_address })

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template = EmailTemplate.find( template_id ) if template_id
#
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#
#    binding = binding()
#    mail(   :to       => ( @recipient? @recipient.formatted_email : to_address ),
#            :from     => @template.formatted_from,
#            :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#            :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

   def beta_invite(to_address,  template_id = nil)
    create_message( binding(), __method__, template_id,  to_address, { :to => to_address })

   # Load interpolate and setup values from template
#     @template = Email.find_by_name!( __method__ ).production_template
#     @template = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", to_address)
#    binding = binding()
#    mail(   :to       => to_address,
#            :from     => @template.formatted_from,
#            :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#            :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def album_shared(from_user_id,to_address,album_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    @recipient = User.find_by_email( to_address )
    create_message( binding(), __method__, template_id, ( @recipient? @recipient : to_address ), { :user_id => @user.id } )

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail(   :to       => ( @recipient? @recipient.formatted_email : to_address ),
#            :from     => @template.formatted_from,
#            :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#            :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def album_updated( recipient_id, album_id,  template_id = nil )
    @album     = Album.find( album_id )
    @user      = @album.user
    @recipient = User.find( recipient_id )
    create_message( binding(), __method__, template_id, @recipient,   { :user_id => @user.id }  )

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

  def contributor_added(album_id, to_address, message, template_id = nil )
    @album = Album.find(album_id)
    @user = @album.user
    @recipient = User.find_by_email( to_address )
    @message = message

    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s
    create_message( binding(), __method__, template_id, ( @recipient? @recipient : to_address ), { :user_id => @user.id })

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => ( @recipient? @recipient.formatted_email : to_address ),
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
  end

   def welcome(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    create_message( binding(), __method__, template_id, @recipient,   { :user_id => @user.id })

    # Load interpolate and setup values from template
#    @template = Email.find_by_name!( __method__ ).production_template
#    @template  = EmailTemplate.find( template_id ) if template_id
#    headers @template.sendgrid_category_header
#    ZZ::ZZA.new.track_event("#{@template.category}.send", @user.id)
#    binding = binding()
#    mail( :to       => @recipient.formatted_email,
#          :from     => @template.formatted_from,
#          :reply_to => ERB.new( @template.formatted_reply_to).result(binding),
#          :subject  => ERB.new( @template.subject).result(binding)
#    ) do |format|
#      format.text { render :inline => @template.text_content }
#      format.html { render :inline => @template.html_content }
#    end
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
        format.text { render :text => "This is the message body of the test" }
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
    #Process recipient
    if recipient.is_a?(User)
      #validate user notification preferences
      @to_address = Mail::Address.new( recipient.formatted_email )
    else
      #validate address' notification preferences
      @to_address = Mail::Address.new( recipient )
    end  

    # Load the appropriate template
    if template_id
      @template  = EmailTemplate.find( template_id )
    else
      @template = Email.find_by_name!( template_name ).production_template
    end

    #set sendgrid category header
    headers @template.sendgrid_category_header

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
  end


end
