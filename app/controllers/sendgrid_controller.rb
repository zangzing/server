require 'mail'
class SendgridController < ApplicationController

  skip_before_filter :verify_authenticity_token


  # This method should be called unsubscribe but it is a reserved ruby word so dont try it
  # catches emails sent to unsubscribe.zangzing.com
  # As part of the subscriptions system, each subscription (i.e. email address) has an unsubscribe token
  # that may be used to unsubscribe by email. The email is of the form  <unsubscribe-token>@unsubscribe.zangzing.com
  # Using the unsubscribe token we try to find the subscription and turn all buckets off
  #
  # A user may also email unsubscribe@unsubscribe.zangzing.com in which case we will unsubscribe the to address
  #
  def un_subscribe  #unsubscribe is a reserved ruby word do not change

    # An unsubscribe email address is of the form  <unsubscribe_token>@unsubscribe.zangzing.com
    # we use Mail::Address to parse the addresses and the domain
    # If the to or from addresses are invalid emails, an exception will be raised
    to          = Mail::Address.new( params[:to].to_slug.to_ascii.to_s  )
    from        = Mail::Address.new( params[:from].to_slug.to_ascii.to_s )
    unsub_token = to.local

    if unsub_token == 'unsubscribe'
      #unsubscribe from address
      @subs = Subscriptions.find_by_email( from.address )
    else
      #unsubscribe using token
      @subs = Subscriptions.find_by_unsubscribe_token( unsub_token )
    end

    if @subs
      @subs.unsubscribe
      zza.track_event("email.unsubscribe.received", {:email => @subs.email, :to => params[:to], :from => params[:from] })
      Rails.logger.info "MAIL UNSUBSCRIBE: #{@subs.email} unsubscribed by email"
    end
    render :nothing => true, :status=> :ok
  end

  #  These are the fields that get posted from SendGrid
  #   text - Text body of email. If not set, email did not have a text body.
  #   html - HTML body of email. If not set, email did not have an HTML body.
  #   to - Email recipient.
  #   from - Email sender.
  #   subject - Email Subject.
  #   dkim - A JSON string containing the verification results of any dkim and domain keys signatures in the message.
  #   spam_score - Spam Assassin's rating for whether or not this is spam.
  #   spam_report - Spam Assassin's spam report.
  #   attachments - Number of attachments included in email.
  #   attachment1, attachment2, …, attachmentN - File upload names. The numbers are sequence numbers starting from 1
  #     and ending on the number specified by the attachments parameter. If attachments is 0, there will be no
  #     attachment files. If attachments is 3, parameters attachment1, attachment2, and attachment3 will have file
  #     uploads.
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
        zza.track_event("email.contributor.received", zza_xtra)

        # An albums email address is of the form  <album_name>@<user_username>.zangzing.com
        # we use Mail::Address to parse the addresses and the domain
        # If the to or from addresses are invalid emails, an exception will be raised
        to             = Mail::Address.new( params[:to].to_slug.to_ascii.to_s  )
        from           = Mail::Address.new( params[:from].to_slug.to_ascii.to_s  )
        album_name     = to.local
        user_username  = to.domain.split('.')[0]
        subject        = params[:subject] #to be used as the caption

        # FIND ALBUM
        # using the info in the to address, find an album
        @album = nil
        begin
          user = User.find_by_username(user_username)
          @album = Album.safe_find(user, album_name)
        rescue ActiveRecord::RecordNotFound => e
          # NEW ALBUM BY EMAIL
          # if album_name is 'new' and the account owner is emailing photos, create a new
          # album with the name set from the subject and all addresses in cc: as contributors
          raise e unless( album_name == 'new' )
          @album = create_new_album( user_username, from.address)
          raise e if( @album.nil? )
        end

        if attachments.count > 0 && @album
          user = @album.get_contributor_user_by_email(from.address, from.display_name)
          if user
            if !subject.match(/^RE:.*/i)
              add_photos(@album, user, attachments, subject)
            else
              # don't use set caption if user is replying to email
              add_photos(@album, user, attachments)
            end

          else
            logger.error "Received a contribution email from an address that is not a contributor. Sending error email"
            ZZ::Async::Email.enqueue(:contribution_error, from.address )
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
        clean_up_temp_files(attachments)
        ZZ::Async::Email.enqueue(:contribution_error, from.address )
        render :nothing => true, :status => :ok
      rescue => ex
        logger.error "Incoming email import failed - WILL NOT RETRY later: " + ex.message
        clean_up_temp_files(attachments)
        render :nothing => true, :status =>:ok # non 200 will cause the mailer to retry
      end
    else
      # call did not come through remapped upload via nginx or we have no attachments so reject it
      logger.error "Incoming email import album invalid arguments or no attachments will not retry."
      ZZ::Async::Email.enqueue(:contribution_error, params[:from] )
      clean_up_temp_files(attachments)
      render :nothing => true, :status=> :ok
    end
  end

  def events
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
        url = params['url']

        # send generic click event for email category
        zza.track_event("#{category}.#{event}", {:email => email }, nil, nil, nil, url)


        # create another click event that identifies the specific link back to zangzing.com
        if(url.match("^http[s]?://[^/]*.zangzing.com"))

          # need to remove "/#!..." and trailing "/" from url before resolving route
          cleaned_url = url.gsub(/\/#!.*|\/$/,'')

          link_name = nil

          if cleaned_url == 'http://www.zangzing.com' 
            link_name = 'zangzing_dot_com_url'
          elsif cleaned_url.match("http://[^/]*.zangzing.com/blog")
            link_name = 'blog_url'
          else
            begin
              route = Rails.application.routes.recognize_path(cleaned_url)

              if route[:controller]=="albums" && route[:action]=="index"
                link_name = "user_homepage_url"
              elsif route[:controller]=="photos" && route[:action]=="show"
                if(url.match(/.*\?show_comments=true/))
                  link_name = 'album_photo_url_with_comments'
                else
                  link_name = 'album_photo_url'
                end
              elsif route[:controller]=="photos" && route[:action]=="index"
                if url.include?("/#!")
                  link_name = "album_photo_url"
                elsif(url.match(/.*\?show_add_photos_dialog=true/))
                  link_name = 'album_grid_url_show_add_photos_dialog'
                else
                  link_name = "album_grid_url"
                end
              elsif route[:controller]=="activities" && route[:action]=="album_index"
                link_name = "album_activities_url"
              elsif route[:controller]=="likes" && route[:action]=="like" && route[:user_id]
                link_name = "like_user_url"
              elsif route[:controller]=="users" && route[:action]=="join"
                link_name = "join_url"
              elsif route[:controller]=="user_sessions" && route[:action]=="new"
                link_name = "signin_url"
              elsif route[:controller]=="albums" && route[:action]=="add_photos"
                link_name = 'album_grid_url_show_add_photos_dialog'
              elsif route[:controller]=="invitations" && route[:action]=="show"
                link_name = 'join_from_invite_url'
              elsif route[:controller]=="invitations" && route[:action]=="invite_friends"
                link_name = 'invite_frields_url'
              end

            rescue ActionController::RoutingError => e
              #unrecognized route
              logger.error "could not find route for #{cleaned_url}"
              logger.info e.backtrace
            end
          end

          if link_name
            zza.track_event("#{category}.#{link_name}.click", {:email => email }, nil, nil, nil, url)
          end

        end

      when 'unsubscribe'
        zza.track_event("#{category}.#{event}", {:email => email })
      else
        zza.track_event("#{category}.#{event}", {:email => email })
    end
    render :nothing => true, :status => 200
  end

  protected
  def create_new_album(  username, from_address )

    # If the account owner is the one emailing
    user = User.find_by_username( username )
    return nil unless( user && user.email == from_address )

    # Create new album
    album  = GroupAlbum.new( )
    album.name = ( params[:subject] && (params[:subject].length > 0) ? params[:subject] : Album::DEFAULT_NAME)
    album.user_id = user.id
    return nil unless( album.save )

    begin
      # Add contributors from cc: if this email created a new album (exception thrown above would prevent this)
      if params[:cc] && params[:cc].length > 0
        ccs = Mail::AddressList.new( params[:cc].to_slug.to_ascii.to_s  )
        users, user_id_to_email = User.convert_to_users(ccs.addresses, user, true)
        group_ids = users.map(&:my_group_id)
        album.add_contributors(group_ids)
      end
    rescue
      # If any exceptions are thrown while parsing contributors
    end
    return album
  end

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
  def add_photos(album, user, attachments, caption=nil)
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
                :caption => ( caption && caption.length > 0 ? caption : fast_local_image["original_name"]),
                :source => 'email',
                #create random uuid for this photo
                :source_guid => "email:"+UUIDTools::UUID.random_create.to_s})
            # use the passed in temp file to attach to the photo
            photo.file_to_upload = file_path
            photos << photo
          rescue Exception => ex
            # if it's any type of error just continue.  Probably just
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
