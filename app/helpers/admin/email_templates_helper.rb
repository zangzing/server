module Admin::EmailTemplatesHelper

  def test_photos_ready( template_id )
      Notifier.photos_ready( upload_batch.id, template_id )
  end

  def test_password_reset( template_id )
      Notifier.password_reset( recipient.id, template_id )
  end

  def test_album_liked(  template_id )
    Notifier.album_liked( sender.id, album.id, template_id)
  end

  def test_photo_liked(  template_id )
    Notifier.photo_liked( sender.id, photo.id, template_id)
  end

  def test_user_liked(  template_id )
      Notifier.user_liked( sender.id, recipient.id, template_id)
  end

  def test_contribution_error(  template_id )
        Notifier.contribution_error( recipient.email, template_id)
  end

  def test_album_shared( template_id )
     Notifier.album_shared( sender.id, recipient.email, album.id, message, template_id)
  end

  def test_album_updated( template_id )
     Notifier.album_updated( recipient.id, album.id, template_id)
  end

  def test_contributor_added( template_id )
       Notifier.contributor_added( album.id, recipient.email, message, template_id)
  end

  def test_welcome( template_id )
       Notifier.welcome( recipient.id, template_id)
  end

  private

  def recipient
    current_user
  end

  def sender
    User.find_by_username!('zangzing')
  end

  def album
    album = nil
    while album.nil? || album.cover.nil?
      album = current_user.albums[ rand( current_user.albums.count) ]
    end
    album
  end

  def photo
    album.photos[ rand( album.photos.count )]
  end


  def upload_batch
    current_user.upload_batches[ rand( current_user.upload_batches.count) ]
  end

  def message
    if rand(2) == 1
    "This message is automatically generated for test emails, Its mimics a custom message written by a user. "+
        "It will be included randomly so you may or may not see it. Do not worry it is not a bug.  "+
        "Proin vestibulum adipiscing neque, ac tincidunt neque pretium a."
    else
      ""
    end
  end
end
