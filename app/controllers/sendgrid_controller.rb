class SendgridController < ApplicationController

  def import
=begin
each album has an email address in the form <album_id>@sendgrid-post.zangzing.com
    *      text - Text body of email. If not set, email did not have a text body.
    *      html - HTML body of email. If not set, email did not have an HTML body.
    *      to - Email recipient.
    *      from - Email sender.
    *      subject - Email Subject.
    *      dkim - A JSON string containing the verification results of any dkim and domain keys signatures in the message.
    *      spam_score - Spam Assassin's rating for whether or not this is spam.
    *      spam_report - Spam Assassin's spam report.
    *      attachments - Number of attachments included in email.
    *      attachment1, attachment2, …, attachmentN - File upload names. The numbers are sequence numbers starting from 1 and ending on the number specified by the attachments parameter. If attachments is 0, there will be no attachment files. If attachments is 3, parameters attachment1, attachment2, and attachment3 will have file uploads.
=end
    album_id = params[:to].match(/\b([A-Z0-9._%+-]+)@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)[1] rescue ''
    album = Album.find_by_id(album_id)
    sender_mail = params[:from].match(/\b([A-Z0-9._%+-]+)@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)[0] rescue ''
    if request.post? && album
      if sender_mail==album.user.email # && album.kind_of?(PersonalAlbum)
        add_photos(album, album.user)
      elsif album.kind_of?(GroupAlbum) && (contributor = album.is_contributor?(sender_mail))
        add_photos(album, contributor)
        album.contributors.find_by_email(sender_mail).last_contribution = DateTime.now
      end
    end
    render :nothing => true, :status => :ok
  end

protected

  def add_photos(album, user)
    photos_count = params[:attachments].to_i
    last_photo = nil
    1.upto(photos_count) do |attach_index|
      attached_image = params["attachment#{attach_index}"]
      photo = Photo.create(
              :caption => attached_image.original_filename,
              :album_id => album.id,
              :user_id => user.id,
              #todo: should use random/uuid/guid for source_guid
              :source_guid => Photo.generate_source_guid("#{params[:html]}_#{params[:text]}_#{Time.now.to_i}_#{attach_index}")
      )
      photo.local_image = attached_image
      photo.save
      last_photo = photo
    end
    last_photo.upload_batch.close if last_photo
  end

end
