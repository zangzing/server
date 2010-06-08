class SharedAlbumMailer < ActionMailer::Base
  def shared_album_notification(share, album_url)
    from       "dev@zangzing.com"
    recipients "dev.zangzing@gmail.com"
    subject    share.email_subject
    body       share.email_message + " " + album_url
  end
end
