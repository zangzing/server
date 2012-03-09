module TrackedLinkHelper

  def check_link_tracking_token
    tracking_token = params[:ref]
    if tracking_token
      handle_tracked_link(tracking_token)
    end
  end

  def current_tracking_token
    session[:tracking_token]
  end

  def handle_tracked_link(tracking_token)
    tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
    if tracked_link  # check in case tracking token got mangled in copy/paste
      TrackedLink.handle_visit(tracking_token, request.referrer)
      session[:tracking_token] = tracking_token

      if !current_user
        set_zzv_id_cookie(tracked_link.zzv_id)
      end

      zza.track_event("invitation.click")
      zza.track_event(tracked_link.click_event_name)

      redirect_to tracked_link.url

      return true
    else
      return false
    end
  end
end