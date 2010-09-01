class Notifier < ActionMailer::Base
  
  default :from => "ZangZing Communications <do-not-reply@zangzing.com>"
  default_url_options[:host] = "localhost:3000"

  def album_upload_complete( user, album )
    recipients user.email
    subject "Your album "+album.name+" is ready!"
    body :user => user, :album => album, :album_url => album_url( album )
  end

  def album_shared_with_you(from_user,to_user,album)
    recipients to_user.email
    subject "#{from_user.name} has shared ZangZing album: #{album.name} with you."
    body    :to_user => to_user, :from_user => from_user, :album => album  
  end

  def password_reset_instructions(user)
    subject       "ZangZing Password Reset Instructions"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def test_email
    recipients  "mauricio@zangzing.com"
    from  "do-not-reply@zangzing.com"
    subject  "Test from ZangZing.com"
    body  "this is the body of the test"
  end

end
