class Notifier < ActionMailer::Base

  if Rails.env == 'production'
    @@zzfrom = '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    @@zzfrom = '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end
  
  default_url_options[:host] = APPLICATION_HOST

  def album_upload_complete( user, album )
    from         @@zzfrom
    recipients user.email
    subject "Your album "+album.name+" is ready!"
    body :user => user, :album => album, :album_url => album_url( album )
  end

  def album_shared_with_you(from_user,to_address,album)
    from         @@zzfrom  
    recipients to_address
    subject "#{from_user.name} has shared ZangZing album: #{album.name} with you."
    body     :from_user => from_user, :album => album  
  end

  def password_reset_instructions(user)
    subject       "ZangZing Password Reset Instructions"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def test_email
    from         @@zzfrom  
    recipients  "mauricio@zangzing.com"
    subject     "Test from ZangZing #{Rails.env.capitalize} Environment"
    body        "this is the body of the test"
  end

   

end
