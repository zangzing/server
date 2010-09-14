class Notifier < ActionMailer::Base

  if Rails.env == 'production'
    @@zzfrom = '"ZangZing Communications" <do-not-reply@zangzing.com>'
  else
    @@zzfrom = '"ZangZing '+Rails.env.capitalize+' Environment" <do-not-reply@zangzing.com>'
  end
  
  default_url_options[:host] = APPLICATION_HOST

  def upload_batch_finished( batch )
    from         @@zzfrom
    recipients batch.user.email
    subject "Your album "+batch.album.name+" is ready!"
    content_type "text/html"
    body :user => batch.user, :album => batch.album, :album_url => album_url( batch.album ), :photos => batch.photos
  end

  def album_shared_with_you(from_user,to_address,album)
    from         @@zzfrom  
    recipients to_address
    subject "#{from_user.name} has shared ZangZing album: #{album.name} with you."
    body     :from_user => from_user, :album => album  
  end

  def you_are_being_followed( follower, followed)
    from @@zzfrom
    recipients followed.email
    subject    "#{follower.name} thinks the world of you"
    content_type "text/html"
    body       :follower => follower, :followed =>followed
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
