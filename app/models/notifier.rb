class Notifier < ActionMailer::Base

  if Rails.env == 'production'
    default :from => '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    default :from => '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end

  def logger
    Rails.logger
  end
  
  def contributors_added(album_id, email, user_id, message )
     @album = Album.find( album_id)
     @user = @album.user
     @album_mail = @album.short_email

     vcard = Vpim::Vcard::Maker.make2 do |vc|
       vc.add_name do |name|
         name.given = @album.name
       end
       vc.add_email @album.short_email
     end
     attachments['album.vcf'] = vcard.to_s

     logger.info "Mailed contributors_added: #{email}, #{@album.long_email}"
     mail( :to        => email,
           :reply_to  => @album.long_email,
           :subject   => "You have been invited to contribute photos to '#{@album.name}'!" )
   end


   def upload_batch_finished( batch_id )
    batch = UploadBatch.find( batch_id )
    @album = batch.album
    @album_url = album_url( @album )
    @photos = batch.photos

    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = batch.album.name
      end
      vc.add_email batch.album.short_email
    end
    attachments["#{batch.album.name}.vcf"] = vcard.to_s
    logger.info "Mailed upload_batch_finished: #{batch.user.email}, #{batch.album.long_email}"
    mail( :to       => batch.user.email,
          :reply_to => batch.album.long_email,
          :subject  => "Your album "+batch.album.name+" is ready!")
  end

 def album_shared_with_you(from_user_id,to_address,album_id, message)
    @from_user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    logger.info "Mailed album_shared_with_you: #{to_address}, #{@album.name}"
    mail( :to      => to_address,
          :subject => "#{@from_user.name} has shared ZangZing album: #{@album.name} with you.")
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

  def password_reset_instructions(user_id)
    user = User.find(user_id)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    logger.info "Mailed password_reset_instructions: #{user.email}"
    mail(  :to      =>    user.email,
           :subject =>    "ZangZing Password Reset Instructions")
  end

  def welcome(user_id)
    user = User.find(user_id)
    @root_url = root_url
    logger.info "Mailed welcome: #{user.email}"
    mail( :to       => user.email,
          :subject  => "Welcome to ZangZing!" )
  end

  def test_email( to )
    logger.info "Mailed test_email: #{to}"
    mail( :to      => to,
          :subject => "Test from ZangZing #{Rails.env.capitalize} Environment") do |format|
        format.text { render :text => "This is the message body of the test" }
    end
  end
end
