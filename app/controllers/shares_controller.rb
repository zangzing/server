#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class SharesController < ApplicationController

  layout false

  respond_to :html, :only => [:new, :newpost, :newemail]
  respond_to :json, :only => [:create]

  def new
  end

  def newpost
    @share = Share.new()
    @twitter  = ( current_user.identity_for_twitter.has_credentials? ? "1" :"0" )
    @facebook = ( current_user.identity_for_facebook.has_credentials? ? "1" :"0" )
  end

  def newemail
    @share = Share.new()
  end

  def create
    # Based on the route used to get here (and thus the params) we know what kind of subject does
    # the user wants to quack! about.
    begin
      @subject, @subject_url, share_event = determine_share_type_from_params
    rescue Exception => ex
      render :json => ex.message, :status => 400 and return
    end

    # make sure recipients its an array
    # emailshare submits a comma separated list of emails
    # postshare submits an array of social services
    if params[:recipients].is_a?(Array)
      @rcp = params[:recipients] #this is post share
      if params[:recipients].include?('twitter')
        zza.track_event("#{share_event}.share.twitter")
      end
      if params[:recipients].include?('facebook')
        zza.track_event("#{share_event}.share.facebook")
      end
    else
      # We are in an email, validate emails, if they ALL pass
      # create share otherwise return error info
      zza.track_event("#{share_event}.share.email")
      emails, errors, addresses, group_ids = Group.filter_groups_and_emails(current_user.id, params[:recipients])


      # log to zza for share analytics
      if @subject.is_a?(Album)
        EmailAnalyticsManager.log_share_message_sent(current_user, :album_shared, emails, errors)
      else
        EmailAnalyticsManager.log_share_message_sent(current_user, :photo_shared, emails, errors)
      end


      # ok, if we have things that aren't valid emails or group names
      # report it to the user
      if errors.length > 0
        flash[:error] = "Please verify highlighted addresses"
        render :json => errors, :status => 200 and return
      end

      # if sharing album by album owner, then add recipients to group
      if @subject.is_a?(Album)
        album = @subject
        if album.admin?( current_user.id )
          # create automatic users if needed
          users, user_id_to_email = User.convert_to_users(addresses, current_user, true)
          view_group_ids = group_ids + users.map(&:my_group_id)
          album.add_viewers(view_group_ids)
        end
      end

      @rcp = emails + group_ids
    end

    @share = Share.new( :user =>        current_user,
                        :subject =>     @subject,
                        :subject_url => @subject_url,
                        :service =>     params[:service],
                        :recipients =>  @rcp,
                        :share_type =>  Share::TYPE_VIEWER_INVITE,
                        :message    =>  params[:message])

    unless @share.save
      errors_to_headers( @share )
      render :json => "", :status => 400 and return
    end

    flash[:notice] = "The user homepage " if @share.user?
    flash[:notice] = "The album " if @share.album?
    flash[:notice] = "The photo " if @share.photo?

    if @share.instant?
      flash[:notice] += "has been shared."
    else
      flash[:notice] += "will be shared as soon as it is ready."
    end
    render :json =>"", :status => 200
  end

  # Sends a share to the specified recipients for the given subject.
  #
  # When sharing a subject that requires permissions to view such
  # as an album, it is up to the caller to make sure that the
  # users given have the appropriate rights.  This is different
  # than the web version where it will auto create viewers for
  # an album.
  #
  # Certain shares will not go out until the subject is in a ready
  # state such as an album that has photos still in the pending
  # state.  In that case, the share will be queued waiting for the
  # current batch to complete and the delayed flag of the result
  # will be set.
  #
  # This is called as (POST):
  #
  # /zz_api/shares/send
  #
  # This call is made in the context of the current logged in user.
  #
  # Input:
  # {
  #   The share subject is one of the following three (only one permitted):
  #   :user_id => the user_id we are sending the message about - we send nothing to email for this one
  #   :album_id => the album_id we are sending the message about
  #   :photo_id => the photo_id we are sending the message about
  #
  #   :message => the message you want to send
  #   :share_type => the share type you are sending (viewer,contributor)
  #
  #   if emails is present we will send the message to the
  #   email addresses given.
  #   :emails => email recipients as an array [
  #     email1,
  #     ...
  #   ],
  #   :group_ids => optional group_ids to send email to as an array [
  #     group1,
  #    ...
  #   ],
  #
  #   :twitter => true or false if you want to send to twitter
  #   :facebook => true or false if you want to send to facebook
  # }
  #
  # Note: currently no validation is done to check to see that twitter and facebook identities
  # are valid, we just check that they are set up.
  #
  # Returns:
  # {
  #   delayed  => true or false depending on whether this share went out immediately
  #               or is waiting for the album batches to finish before it will be sent
  # }
  #
  # Errors:
  # If we have a list validation error with either the emails, or group_ids we collect the items that were
  # in error into a list for each type and raise an exception. The exception will be returned to the client
  # as json in the standard error format.  The code will be INVALID_LIST_ARGS (1001) and the
  # message part of the error will contain:
  #
  # {
  #   :emails => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the invalid email,
  #       :error => an error string
  #     }
  #     ...
  #   ],
  #   :group_ids => [
  #     {
  #       :index => the index in the corresponding input list location,
  #       :token => the missing group_id,
  #       :error => an error string, may be blank
  #     }
  #     ...
  #   ],
  # }
  def zz_api_send
    return unless require_user

    zz_api do
      # validate the input
      emails, email_errors, addresses = ZZ::EmailValidator.validate_email_list(params[:emails])

      message = params[:message] || ''
      share_type = params[:share_type]
      raise ArgumentError.new("No share type specified") if share_type.nil?

      # grab any group ids and get the allowed ones
      group_ids = params[:group_ids]
      if group_ids
        found_group_ids = Group.allowed_group_ids(current_user.id, group_ids)
        missing_group_ids = ZZAPIInvalidListError.build_missing_list(group_ids, Set.new(found_group_ids))
        group_ids = found_group_ids
      else
        group_ids = []
        missing_group_ids = []
      end

      # verify that groups and emails are ok
      unless missing_group_ids.empty? && email_errors.empty?
        # got at least one error, so raise the exception
        raise ZZAPIInvalidListError.new({:group_ids => missing_group_ids, :emails => email_errors})
      end
      email_to = emails + group_ids

      # get the info about the share type
      subject, subject_url, share_event = determine_share_type_from_params

      delayed = false

      # see if we have twitter and/or facebook
      socials = []
      add_social(socials, 'twitter') if !!params[:twitter]
      add_social(socials, 'facebook') if !!params[:facebook]

      if !socials.empty?
        # we have some socials so send the share
        share = Share.new( :user =>         current_user,
                            :subject =>     subject,
                            :subject_url => subject_url,
                            :service =>     Share::SERVICE_SOCIAL,
                            :recipients =>  socials,
                            :share_type =>  share_type,
                            :message    =>  message)
        share.save!
        zza_send_socials(socials, share_event)
        delayed ||= !share.instant?
      end

      # and now the emails
      if !email_to.empty?
        # we have some emails so send the share
        share = Share.new( :user =>         current_user,
                            :subject =>     subject,
                            :subject_url => subject_url,
                            :service =>     Share::SERVICE_EMAIL,
                            :recipients =>  email_to,
                            :share_type =>  share_type,
                            :message    =>  message)
        share.save!
        zza.track_event("#{share_event}.share.email")
        delayed ||= !share.instant?
      end

      { :delayed => delayed }
    end
  end


  def new_twitter_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      message = "Check out #{user.posessive_name} Albums on @ZangZing"
      zza.track_event('user.share.twitter')
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      message = "Check out #{album.user.posessive_name} #{album.name} Album on @ZangZing"
      zza.track_event('album.share.twitter')
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      message = "Check out #{photo.user.posessive_name} photo on @ZangZing"
      zza.track_event('photo.share.twitter')
    end

    shareable_url = bitly_url(shareable_url)
    redirect_to "http://twitter.com/share?text=#{URI.escape message}&url=#{URI.escape shareable_url}"

  end

  def new_facebook_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      zza.track_event('user.share.facebook')
    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      zza.track_event('album.share.facebook')
    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      zza.track_event('photo.share.facebook')
    end

    redirect_to "http://www.facebook.com/share.php?u=#{URI.escape shareable_url}"

  end

  def new_mailto_share
    if  params[:user_id]
      user = User.find(params[:user_id])
      shareable_url = user_pretty_url(user)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out a ZangZing homepage"
      message = "Hi, I thought you would like to see this ZangZing homepage.\n\n #{shareable_url}"
      zza.track_event('user.share.email')

    elsif params[:album_id]
      album = Album.find(params[:album_id])
      shareable_url = album_pretty_url(album)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out #{album.name} album on ZangZing"
      message = "Hi, I thought you would like to see #{album.user.posessive_name} #{album.name} album on ZangZing.\n\n #{shareable_url}"
      zza.track_event('album.share.email')

    elsif params[:photo_id]
      photo = Photo.find(params[:photo_id])
      shareable_url = photo_pretty_url(photo)
      shareable_url = bitly_url(shareable_url)
      subject = "Check out this photo on ZangZing"
      message = "Hi, I thought you would like to see #{photo.user.posessive_name} photo on ZangZing.\n\n #{shareable_url}"
      zza.track_event('photo.share.email')

    end

    render :json=> {:mailto => "mailto:?subject=#{URI.escape subject}&body=#{URI.escape message}"}

  end



private
  # takes the incoming params and determines the share type
  # based on what was passed.  The valid types that we look
  # for are:
  # user_id
  # album_id
  # photo_id
  #
  # we return the share info via
  # subject => the user, album, or photo
  # url => the url to the subject
  # share_event => the name to add to the zza event (user, photo, album)
  #
  # raises an argument error if a valid type is not specified
  #
  def determine_share_type_from_params
    # Based on the route used to get here (and thus the params) we know what kind of subject does
    # the user wants to quack! about.
    if  params[:user_id]
      subject = User.find(params[:user_id])
      url = user_pretty_url(subject)
      share_event = 'user'
    elsif params[:album_id]
      subject = Album.find(params[:album_id])
      url = album_pretty_url(subject)
      share_event = 'album'
    elsif params[:photo_id]
      subject = Photo.find(params[:photo_id])
      url = photo_pretty_url(subject)
      share_event = 'photo'
    else
      raise ArgumentError.new("subject_type of user_id, album_id, or photo_id not specified via params")
    end

    return subject, url, share_event
  end

  # add the social type we are sending to
  def add_social(socials, social_type)
    identity = current_user.send("identity_for_#{social_type}".to_sym)
    raise ArgumentError.new("#{social_type} identity is not valid") unless identity.has_credentials?
    socials << social_type
  end

  # send the zza events for the socials
  def zza_send_socials(socials, share_event)
    socials.each do |social_type|
      zza.track_event("#{share_event}.share.#{social_type}")
    end
  end
end