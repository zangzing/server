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
    album_id = params[:to].split('@').first
    album = Album.find_by_id(album_id)
    sender_mail = params[:from]
    if request.post? && album && sender_mail==album.user.email
      photos_count = params[:attachments].to_i
      1.upto(photos_count) do |attach_index|
        attached_image = params["attachment#{attach_index}"]
        photo = Photo.create(
                :caption => attached_image.original_filename,
                :album_id => album_id,
                :user_id => album.user.id,
                :source_guid => Photo.generate_source_guid("#{params[:html]}_#{params[:text]}_#{Time.now.to_i}_#{attach_index}")
        )
        photo.local_image = attached_image
        photo.save
      end
    end
    render :nothing => true, :status => :ok
  end

end
