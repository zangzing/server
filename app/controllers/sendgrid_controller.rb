require 'mail'
class SendgridController < ApplicationController

  skip_before_filter :verify_authenticity_token

=begin
each album has an email address in the form <album_name>@<username>.zangzing.com
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
  def import_fast
    # make sure the call came from nginx
    # currently we only allow through to, from, attachments, and the attachments in the form:
    # photo[fast_local_image][original_name]
    # photo[fast_local_image][content_type]
    # photo[fast_local_image][filepath]
    #
    # if you need other fields passed through modify the custom.locations.conf config file
    # for nginx
    #
    if params[:fast_upload_secret] == "this-is-a-key-from-nginx" && (attachments=params[:fast_local_image])
      begin
        # report data to zza
        zza_xtra = {
            :SPF => params[:SPF],
            :dkim => params[:dkim],
            :from => params[:from],
            :to => params[:to],
            :spam_report => params[:spam_report],
            :spam_score => params[:spam_score],
        }
        ZZ::ZZA.new.track_event("email.contributor.received", zza_xtra)

        
        # An albums email address is of the form  <album_name>@<user_username>.zangzing.com
        # we use Mail::Address to parse the addresses and the domain
        # If the to or from addresses are invalid emails, an exception will be raised
        to             = Mail::Address.new( params[:to] )
        from           = Mail::Address.new( params[:from] )
        album_name     = to.local
        user_username  = to.domain.split('.')[0]

        @album = nil
        begin
          @album = Album.find(album_name, :scope => user_username )
        rescue ActiveRecord::RecordNotFound => e
          if album_name == 'new'
            user = User.find_by_username!( user_username )
            # If the account owner is the one emailing
            if user.email == from.address
              @album  = GroupAlbum.new()
              user.albums << @album
              @album.name = ( params[:subject] && params[:subject].length > 0 ? params[:subject] : "New Album By Email")
              @album.save!
            else
              raise e
            end
          else
            raise e 
          end
        end

        # NEW ALBUM BY EMAIL
        # if album_name is 'new' and the account owner is emailing photos, create a new
        # album with the name set from the subject and all addresses in cc: as contributors
        if attachments.count > 0 && @album
          user = @album.get_contributor_user_by_email( from.address )
          if user
            add_photos(@album, user, attachments)
          end
        end

        # Add contributors from cc: if this email created a new album
        if album_name == 'new' && @album
           if params[:cc] && params[:cc].length > 0
              ccs = Mail::AddressList.new( params[:cc] )
              ccs.addresses.each do | contributor|
                @album.add_contributor( contributor.address )
              end
           end
        end

        render :nothing => true, :status => :ok

      rescue ActiveRecord::RecordNotFound => ex
        # for not found just log it and return ok so the mailer stops hitting us with this bad email
        # other errors will be logged but retries will continue
        logger.error "Incoming email import album not found will not retry: " + ex.message
        # since we are returning status 200 to nginx it will not delete the temp files for us
        # and in this case we are done with them. We return 200 to make sendgrid stop sending
        # since we can't do anything more with this message in the future and that is the
        # only status code they will stop sending on
        ZZ::Async::Email.enqueue(:contribution_error, from.address )
        clean_up_temp_files(attachments)
        render :nothing => true, :status => :ok
      rescue => ex
        logger.warn "Incoming email import failed - will retry later: " + ex.message
        render :nothing => true, :status => 400 # non 200 will cause the mailer to retry
      end
    else
      # call did not come through remapped upload via nginx or we have no attachments so reject it
      logger.error "Incoming email import album invalid arguments or no attachments will not retry."
      clean_up_temp_files(attachments)
      render :nothing => true, :status=> :ok
    end
  end

  def events
    zza      = ZZ::ZZA.new('sendgrid/rack')
    event    =  params['event']
    email    =  params['email']
    category =  params['category']
    case event
      when 'processed'
        zza.track_event("#{category}.#{event}", {:email => email })
      when 'dropped'
        zza.track_event("#{category}.#{event}", {:email => email, :reason => params['reason']})
      when 'deferred'
        zza.track_event("#{category}.#{event}", {:email => email, :response => params['response'], :attempt => params['attempt']})
      when 'delivered'
        zza.track_event("#{category}.#{event}", {:email => email, :response => params['response']})
      when 'bounce'
        zza.track_event("#{category}.#{event}", {:email => email, :status=> params['status'], :reason => params['reason'], :type => params['type']})
        #TODO: Process Bounce
      when 'spamreport'
        zza.track_event("#{category}.#{event}", {:email => email })
        #TODO: Process SpamReport
      when 'click'
        zza.track_event("#{category}.#{event}", {:email => email }, nil, nil, nil, params['url'])
      when 'unsubscribe'
        zza.track_event("#{category}.#{event}", {:email => email })
        #TODO Process unsubscribe
      else
        zza.track_event("#{category}.#{event}", {:email => email })
    end
    render :nothing => true, :status => 200
  end
  
protected

  # due to the fact that we need to return status 200 to sendgrid to get them to stop
  # sending to us we need to clean up here rather than back in nginx because it does not
  # clean up on 200 status codes since normally that indicates success and that we will
  # take care of cleanup later - in this case we actually treat 200 as just an indication
  # that we want no more retries sent to us which could be because of success or a failure
  # condition we cannot recover from
  def clean_up_temp_files(attachments)
    if attachments
      attachments.each do |fast_local_image|
        # do the delete since we no longer need the temp file
        # and nginx is not going to clean up in this case
        path = fast_local_image['filepath']
        remove_file(path)
      end
    end
  end

  def remove_file(path)
    (File.delete(path) unless path.nil?) rescue nil #ignore any error
  end

  # take the incoming file attachments and make photos out of them
  def add_photos(album, user, attachments)
    if attachments.count > 0
      photos = []
      current_batch = UploadBatch.get_current_and_touch( user.id, album.id )
      attachments.each do |fast_local_image|
        content_type = fast_local_image['content_type']
        file_path = fast_local_image['filepath']
        if Photo.valid_image_type?(content_type) == false
          # not a valid file type, just ignore and remove file
          remove_file(file_path)
        else
          begin
            photo = Photo.new_for_batch(current_batch, {
                    :id => Photo.get_next_id,
                    :user_id => user.id,
                    :album_id => album.id,
                    :upload_batch_id => current_batch.id,
                    :caption => fast_local_image["original_name"],
                    :source => 'email',
                    #create random uuid for this photo
                    :source_guid => "email:"+UUIDTools::UUID.random_create.to_s})
            # use the passed in temp file to attach to the photo
            photo.file_to_upload = file_path
            # in this case because we just fetched the capture time of the photo
            # directly set the default position.  Normally it is passed in when the
            # photo object is created because it is known ahead of time
            photo.set_default_position
            photos << photo
          rescue PhotoValidationError => ex
            # if it's a validation error, ignore and continue.  Probably just
            # a bad type of upload (i.e. not a photo)
          end
        end
      end

      # bulk insert
      Photo.batch_insert(photos)
      current_batch.close()
    end
  end

  def spam_report

  end

  def bounce

  end

  def unsubscribe

  end
   
end
