class InvitationsController < ApplicationController

  ssl_required :show


  def send_reminder
    return unless require_user
    Invitation.send_reminder(params[:invitation_id])
    render :json=>JSON.fast_generate({})
  end

  def invite_friends
    return unless require_user

    @show_back_button = true
    @invite_url_for_copy_paste = Invitation.get_invitation_link_for_copy_paste(current_user)
  end

  def send_to_twitter
    return unless require_user
    zza.track_event('invitation.share.twitter')

    message = params[:message]

    shareable_url = bitly_url(Invitation.get_invitation_link_for_twitter(current_user))
    redirect_to "http://twitter.com/share?text=#{URI.escape message}&url=#{URI.escape shareable_url}"

  end

  def send_to_facebook
    return unless require_user
    zza.track_event('invitation.share.facebook')


    # sample...
    # http://www.facebook.com/sharer/sharer.php?s=100&p%5Btitle%5D=Daddy+Design&p%5Bsummary%5D=Become+a+fan+of+Daddy+Design%21&p%5Burl%5D=http%3A%2F%2Fwww.facebook.com%2Fwordpressdesign&p%5Bimages%5D%5B0%5D=http%3A%2F%2Fwww.daddydesign.com%2FClientsTemp%2FTutorials%2Fcustom-iframe-share-button%2Fimages%2Fthumbnail.jpg&

    title = 'ZangZing'
    shareable_url = bitly_url(Invitation.get_invitation_link_for_facebook(current_user))
    message = "ZangZing is a simple and beautiful way to organize, view, and share your photos. Join and get 2GB of free photo storage plus a 250MB bonus at #{shareable_url}"

    redirect_to "http://www.facebook.com/sharer/sharer.php?s=100&p[url]=#{URI.escape shareable_url}&p[title]=#{URI.escape title}&p[summary]=#{URI.escape message}"
  end

  def send_to_email
    return unless require_user

    emails, errors = ZZ::EmailValidator.validate_email_list(params[:emails])

    already_joined_emails = []

    emails.each do |email|
      if User.find_by_email(email)
        already_joined_emails << email
      else
        Invitation.create_and_send_invitation(current_user, email)
      end
    end

    render :json=>JSON.fast_generate({:already_joined => already_joined_emails})
  end


  def show
    return unless require_no_user

    tracked_link = TrackedLink.find_by_tracking_token(current_tracking_token)
    if tracked_link
      send_zza_event_from_client("invitation.click")
      send_zza_event_from_client("invitation.#{tracked_link.shared_to}.click")
      @friends_name = tracked_link.user.name
    else
      @friends_name = 'your friend'
    end
    
    @message_title = "You’ve been invited to join ZangZing!"
    @message = "Join and you and #{@friends_name} get 250MB of extra space on top of the 2GB you already get for free!!"
    
    render "/users/join", :layout => false
  end

end