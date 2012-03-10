class Notifier < ActionMailer::Base
  include ZZ::Mailer
  include PrettyUrlHelper
  include TrackingHelper
  add_template_helper(TrackingHelper)
  add_template_helper(PrettyUrlHelper)

  include OrderNotifier


  def photos_ready( batch_id, template_id = nil )
    @batch   = UploadBatch.find( batch_id )
    @user    = @batch.user
    @album   = @batch.album
    @photos  = @batch.photos
    @recipient = @user
    @album_url = album_pretty_url( @album )


    @invite_friends_url = invite_friends_url
    @join_now_url = join_url
    @recipient_is_user = true


    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    create_message( __method__, template_id, @recipient,  { :user_id => @user.id })
  end




  def password_reset(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @password_reset_url = bitly_url(edit_password_reset_url(@user.perishable_token))
    # Add a header for fast delivery
    sendgrid_headers.merge!( {'bypass_list_management' => { 'enable' => 1 }} )

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def album_liked( user_id, album_id, recipient_user_id, template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = User.find(recipient_user_id)

    @invite_friends_url = invite_friends_url
    @join_now_url = join_url
    @recipient_is_user = true



    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def photo_liked( user_id, photo_id, recipient_id, template_id = nil )
    @user      = User.find( user_id )
    @photo     = Photo.find( photo_id )
    @recipient = User.find( recipient_id )

    @invite_friends_url = invite_friends_url
    @join_now_url = join_url
    @recipient_is_user = true



    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def user_liked( user_id, liked_user_id,  template_id = nil )
    @user      = User.find( user_id )
    @recipient = User.find( liked_user_id )

    @invite_friends_url = invite_friends_url
    @join_now_url = join_url
    @recipient_is_user = true


    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def contribution_error( to_address, template_id = nil)
    @recipient = User.find_by_email( to_address )

    create_message(  __method__, template_id, ( @recipient? @recipient : to_address ), { :to => to_address })
  end




  def photo_shared(from_user_id,to_address,photo_id, message, template_id = nil)
    @user = User.find(from_user_id)
    @photo = Photo.find(photo_id)
    @message = message
    rcp_user = User.find_by_email( to_address )
    @recipient = ( rcp_user ? rcp_user : to_address )

    @recipient_is_user = true

    @join_now_url = nil
    @photo_pretty_url = photo_pretty_url_no_hash_bang(@photo)
    @photo_url_with_comments = photo_url_with_comments(@photo)
    @invite_friends_url = invite_friends_url

    # all shares to non-users should
    # be treated as invitation
    if !rcp_user || rcp_user.automatic?
      @recipient_is_user = false

      invitation = Invitation.find_or_create_invitation_for_email(@user, to_address, invitation_url, TrackedLink::TYPE_PHOTO_SHARE)
      @join_now_url = invitation.tracked_link.long_tracked_url
      @photo_pretty_url = TrackedLink.create_tracked_link(@user, @photo_pretty_url, TrackedLink::TYPE_PHOTO_SHARE, TrackedLink::SHARED_TO_EMAIL, to_address).long_tracked_url
      @photo_url_with_comments = TrackedLink.create_tracked_link(@user, @photo_url_with_comments, TrackedLink::TYPE_PHOTO_SHARE, TrackedLink::SHARED_TO_EMAIL, to_address).long_tracked_url
      @invite_friends_url = nil

      send_share_invite_zza_event(@user, invitation.tracked_link)
    end


    create_message(  __method__, template_id, @recipient, { :to => to_address })
  end




  def beta_invite(to_address,  template_id = nil)
    create_message(  __method__, template_id,  to_address, { :to => to_address })
  end




  def album_shared(from_user_id,to_address,album_id, message, template_id = nil)
    @user = User.find(from_user_id)
    rcp_user = User.find_by_email( to_address )
    @album = Album.find(album_id)
    @message = message
    @recipient = ( rcp_user ? rcp_user : to_address )

    @recipient_is_user = true

    @join_now_url = nil
    @album_pretty_url = album_pretty_url(@album)
    @invite_friends_url = invite_friends_url

    # all shares to non-users should
    # be treated as invitation
    if !rcp_user || rcp_user.automatic?
      @recipient_is_user = false

      invitation = Invitation.find_or_create_invitation_for_email(@user, to_address, invitation_url, TrackedLink::TYPE_PHOTO_SHARE)
      @join_now_url = invitation.tracked_link.long_tracked_url
      @album_pretty_url = TrackedLink.create_tracked_link(@user, @album_pretty_url, TrackedLink::TYPE_ALBUM_SHARE, TrackedLink::SHARED_TO_EMAIL, to_address).long_tracked_url
      @invite_friends_url = nil

      send_share_invite_zza_event(@user, invitation.tracked_link)


    end



    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end




  def album_updated( from_user_id, to_address_or_id, album_id, batch_id,  template_id = nil )
    @album     = Album.find( album_id )
    @user      = User.find( from_user_id )
    @batch     = UploadBatch.find( batch_id )
    @photos    = @batch.photos
    # if to_address_or_id is an email, we already know that the email is not a user yet.
    rcp_user = User.find_by_id( to_address_or_id )
    @recipient = ( rcp_user ? rcp_user : to_address_or_id )
    @destination_link = destination_link( @recipient, album_pretty_url( @album ) )

    @invite_friends_url = invite_friends_url
    @join_now_url = join_url
    @recipient_is_user = @recipient.is_a?(User) && !@recipient.automatic?

    create_message(  __method__, template_id,  @recipient, { :user_id => @user.id } )
  end




  def contributor_added(album_id, to_address, message, template_id = nil )
    rcp_user = User.find_by_email( to_address )
    @album = Album.find(album_id)
    @user = @album.user
    @message = message
    @recipient = ( rcp_user ? rcp_user : to_address )

    @recipient_is_user = true

    @join_now_url = nil
    @album_pretty_url = album_pretty_url(@album)
    @invite_friends_url = invite_friends_url
    @album_pretty_url_show_add_photos_dialog = album_pretty_url_show_add_photos_dialog(@album)

    # all shares to non-users should
    # be treated as invitation
    if !rcp_user || rcp_user.automatic?
      @recipient_is_user = false

      invitation = Invitation.find_or_create_invitation_for_email(@user, to_address, invitation_url, TrackedLink::TYPE_PHOTO_SHARE)
      @join_now_url = invitation.tracked_link.long_tracked_url
      @album_pretty_url = TrackedLink.create_tracked_link(@user, @album_pretty_url, TrackedLink::TYPE_CONTRIBUTOR_INVITE, TrackedLink::SHARED_TO_EMAIL, to_address).long_tracked_url
      @album_pretty_url_show_add_photos_dialog = TrackedLink.create_tracked_link(@user, @album_pretty_url_show_add_photos_dialog, TrackedLink::TYPE_ALBUM_SHARE, TrackedLink::SHARED_TO_EMAIL, to_address).long_tracked_url
      @invite_friends_url = nil

      send_share_invite_zza_event(@user, invitation.tracked_link)

    end

    vcard = Vpim::Vcard::Maker.make2 do |vc|
      vc.add_name do |name|
        name.given = @album.name
      end
      vc.org = "ZangZing"
      vc.add_email @album.short_email
    end
    attachments["#{@album.name}.vcf"] = vcard.to_s

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )

  end




  def welcome(user_id, template_id = nil)
    @user = User.find(user_id)
    @recipient = @user
    @joined_from_invitation = @user.received_invitations.find_by_status(Invitation::STATUS_COMPLETE)

    create_message(  __method__, template_id, @recipient,   { :user_id => @user.id })
  end


  def request_access( user_id, album_id,  message,template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user
    @message   = message

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end

  def request_contributor( user_id, album_id,  message,template_id = nil )
    @user      = User.find( user_id )
    @album     = Album.find( album_id )
    @recipient = @album.user
    @message   = message

    create_message(  __method__, template_id, @recipient, { :user_id => @user.id } )
  end



  def activation_instructions(user_id)
    user = User.find(user_id)
    @account_activation_url = activate_url(user.perishable_token)
    logger.info "Mailed activation_instructions: #{user.email}"
    mail( :to      => user.email,
          :subject => "Account Activation Instructions for your ZangZing Account" )
  end




  def test_email( to )
    logger.info "Mailed test_email: #{to}"
    mail( :to      => to,
          :subject => "Test from ZangZing #{Rails.env.capitalize} Environment") do |format|
      format.text { render :inline => " <%=message.to.to_s%> This is the message body of the test" }
    end
  end

  def photo_comment(comment_added_by_user_id, send_notification_to_user_id_or_address, comment_id, template_id = nil)
    @user = User.find(comment_added_by_user_id)
    @comment = Comment.find(comment_id)
    @photo = @comment.commentable.subject
    # if send_notification_to_user_id_or_address is an email, we already know that the email is not a user yet.
    rcp_user = User.find_by_id( send_notification_to_user_id_or_address )
    @recipient = ( rcp_user ? rcp_user : send_notification_to_user_id_or_address )
    create_message( __method__, template_id,  @recipient, { :user_id => @user.id } )
  end


  def invite_to_join(from_user_id, to_email_address, invite_url, template_id = nil)
    @user = User.find_by_id(from_user_id)
    @recipient = to_email_address
    @invite_url = invite_url

    create_message( __method__, template_id,  @recipient, { :user_id => @user.id } )
  end


  def joined_from_invite(invitation_id, received_bonus, template_id = nil)
    @invitation = Invitation.find_by_id(invitation_id)
    @user = @invitation.invited_user
    @recipient = @invitation.user
    @received_bonus = received_bonus
    create_message( __method__, template_id,  @recipient, { :user_id => @user.id } )
  end



  private
  def send_share_invite_zza_event(user, tracked_link)

    # events tied to user sending the email
    zza = ZZ::ZZA.new
    zza.user_type = 1
    zza.user = user.id
    zza.zzv_id = user.zzv_id
    zza.track_event("invitation.send")
    zza.track_event(tracked_link.send_event_name)

    # events tied to user receiving email
    # since this is an 'invite' we can assume that recipient
    # is not a user (yet)
    zza = ZZ::ZZA.new
    zza.user_type = 2
    zza.user = tracked_link.zzv_id
    zza.zzv_id = tracked_link.zzv_id
    zza.track_event("invitation.sent_to")
    zza.track_event(tracked_link.sent_to_event_name)
  end


end

