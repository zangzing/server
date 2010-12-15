class Notifier < ActionMailer::Base

  if Rails.env == 'production'
    default :from => '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    default :from => '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end

  def contributors_added(contributor_id)
     contributor = Contributor.find( contributor_id )
     @user = contributor.album.user
     @album = contributor.album
     @album_mail = contributor.album.short_email

     vcard = Vpim::Vcard::Maker.make2 do |vc|
       vc.add_name do |name|
         name.given = contributor.album.name
       end
       vc.add_email contributor.album.short_email
     end
     attachments['album.vcf'] = vcard.to_s
     #attachments['album.vcf'] = {:mime_type => 'text/x-vcard',:content =>vcard.to_s}

     mail( :to        => contributor.email,
           :reply_to  => contributor.album.long_email,
           :subject   => "You have been invited to contribute photos to '#{contributor.album.name}'!" )
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
    #attachments["#{batch.album.name}.vcf"] = {:mime_type => 'text/x-vcard',:content =>vcard.to_s}

    mail( :to       => batch.user.email,
          :reply_to => batch.album.long_email,
          :subject  => "Your album "+batch.album.name+" is ready!")
  end

 def album_shared_with_you(from_user_id,to_address,album_id, message)
    @from_user = User.find(from_user_id)
    @album = Album.find(album_id)
    @message = message
    mail( :to      => to_address,
          :subject => "#{@from_user.name} has shared ZangZing album: #{@album.name} with you.")
  end

  def you_are_being_followed( follower_id, followed_id)
    @follower = User.find( follower_id )
    @followed = User.find( followed_id )
    mail( :to      => @followed.email,
          :subject => "#{@follower.name} thinks the world of you")
  end

  def activation_instructions(user_id)
    user = User.find(user_id)
    @account_activation_url = activate_url(user.perishable_token)
    mail( :to      => user.email,
          :subject => "Account Activation Instructions for your ZangZing Account" )
  end

  def password_reset_instructions(user_id)
    user = User.find(user_id)
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    mail(  :to      =>    user.email,
           :subject =>    "ZangZing Password Reset Instructions")
  end

  def welcome(user_id)
    user = User.find(user_id)
    @root_url = root_url
    mail( :to       => user.email,
          :subject  => "Welcome to ZangZing!" )
  end

  def test_email( to )
    mail( :to      => to,
          :subject => "Test from ZangZing #{Rails.env.capitalize} Environment") do |format|
        format.text { render :text => "This is the message body of the test" }
    end
  end
end
