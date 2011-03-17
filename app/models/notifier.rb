class Notifier < ActionMailer::Base

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
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    #Load interpolate and setup values from template
    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def password_reset(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @password_reset_url = edit_password_reset_url(@user.perishable_token)

    # Load interpolate and setup values from template
    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail(  :to       => @recipient.formatted_email,
           :from     => @template.formatted_from,
           :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
           :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def album_liked( user_id, album_id,  template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def photo_liked( user_id, photo_id,  template_id = nil )
    @user      = User.find( user_id )
    @photo     = Photo.find( photo_id )
    @recipient = @photo.user

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def user_liked( user_id, liked_user_id,  template_id = nil )
    @user      = User.find( user_id )
    @recipient = User.find( liked_user_id )

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def contribution_error( to_address, template_id = nil)
        @recipient = User.find_by_email( to_address )
        @template = Email.find_by_name!( __method__ ).production_template
        @template  = EmailTemplate.find( template_id ) if template_id

        headers @template.sendgrid_category_header
        binding = binding()
        mail(   :to       => ( @recipient? @recipient.formatted_email : to_address ),
                :from     => @template.formatted_from,
                :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
                :subject  => ERB.new( @template.subject).result(binding)
        ) do |format|
          format.text { render :inline => @template.text_content }
          format.html { render :inline => @template.html_content }
        end
  end


  def album_shared(from_user_id,to_address,album_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    @recipient = User.find_by_email( to_address )

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id

    headers @template.sendgrid_category_header
    binding = binding()
    mail(   :to       => ( @recipient? @recipient.formatted_email : to_address ),
            :from     => @template.formatted_from,
            :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
            :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

  def album_updated( recipient_id, album_id,  template_id = nil )
    @album     = Album.find( album_id )
    @user      = @album.user
    @recipient = User.find( recipient_id )

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
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
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    #Load interpolate and setup values from template
    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => ( @recipient? @recipient.formatted_email : to_address ),
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end

   def welcome(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user

    @template = Email.find_by_name!( __method__ ).production_template
    @template  = EmailTemplate.find( template_id ) if template_id
    headers @template.sendgrid_category_header
    binding = binding()
    mail( :to       => @recipient.formatted_email,
          :from     => @template.formatted_from,
          :reply_to => ERB.new( @template.formatted_reply_to).result(binding), #@album.short_email
          :subject  => ERB.new( @template.subject).result(binding)
    ) do |format|
      format.text { render :inline => @template.text_content }
      format.html { render :inline => @template.html_content }
    end
  end



  def you_are_being_followed( follower_id, followed_id)
    @follower = User.find( follower_id )
    @followed = User.find( followed_id )
    logger.info "Mailed you_are_being_followed: #{@followed.email}, #{@follower.name}"
    mail( :to      => @followed.email,
          :subject => "#{@follower.name} thinks the world of you")
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

  def like_album( album_id, liker_id )
    @album = Album.find( album_id )
    @user  = @album.user
    @liker = User.find( liker_id )

    # Load interpolate and setup values from template
    @email_template = EmailTemplate.find_by_name!( __method__ )
    subject = ERB.new( @email_template.subject).result
    from = @email_template.from

    logger.info "Mailed like_album: #{@user.username}, #{@album.name}"
    mail( :to      => to_address,
          :from    => from,
          :subject => subject ) do |format|
        format.text { render :inline => @email_template.text_content }
        format.html { render :inline => @email_template.html_content }
    end
  end
end
