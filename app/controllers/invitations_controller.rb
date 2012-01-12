class InvitationsController < ApplicationController

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

    emails.each do |email|
      Invitation.send_invitation_to_email(current_user, email)
    end

    render :json=>JSON.fast_generate({})
  end


  def show
    redirect_to join_url
  end

end