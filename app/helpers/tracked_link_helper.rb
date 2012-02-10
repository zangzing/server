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

      send_zza_event_from_client("invitation.click")
      send_zza_event_from_client(tracked_link.click_event_name)

      redirect_to tracked_link.url

      return true
    else
      return false
    end
  end
end