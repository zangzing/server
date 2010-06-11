class Mailer < ActionMailer::Base
  def shared_album_notification(share, album_url)
    from       "dev@zangzing.com"
    recipients "dev.zangzing@gmail.com"
    subject    share.email_subject
    body       share.email_message + " " + album_url
  end

  default_url_options[:host] = "localhost:3000"

  def password_reset_instructions(user)
    subject       "ZangZing Password Reset Instructions"
    from          "ZangZing"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

end
