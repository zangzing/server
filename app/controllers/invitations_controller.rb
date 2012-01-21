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

    message = params[:message]


    shareable_url = bitly_url(Invitation.get_invitation_link_for_facebook(current_user))
    redirect_to "http://www.facebook.com/share.php?u=#{URI.escape shareable_url}&t=#{URI.escape message}"
  end

  def send_to_email
    return unless require_user

    emails, errors = ZZ::EmailValidator.validate_email_list(params[:emails])

    already_joined_emails = []

    emails.each do |email|
      if User.find_by_email(email)
        already_joined_emails << email
      else
        Invitation.send_invitation_to_email(current_user, email)
      end
    end

    render :json=>JSON.fast_generate({:already_joined => already_joined_emails})
  end


  def show
    return unless require_no_user


    tracked_link = TrackedLink.find_by_tracking_token(current_tracking_token)
    if tracked_link
      @friends_name = tracked_link.user.name
      render :layout => false
    else
      @friends_name = 'your friend'
      render :layout => false
      #redirect_to join_url
    end
  end

end