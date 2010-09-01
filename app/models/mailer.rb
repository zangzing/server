#
#   © 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#


class Mailer < ActionMailer::Base
  default_url_options[:host] = "localhost:3000"
  default :from => "ZangZing Communications <do-not-reply@zangzing.com>" 

  def album_upload_complete_message( user, album )
    recipients user.email
    subject "Your album "+album.name+" is ready!"
  end

  def album_shared_with_you_message(from_user,to_user,album)
    recipients to_user.email
    subject "#{from_user.name} has shared a ZangZing album: #{album.name} with you."
  end

  def password_reset_instructions(user)
    subject       "ZangZing Password Reset Instructions"
    from          "ZangZing"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

end
