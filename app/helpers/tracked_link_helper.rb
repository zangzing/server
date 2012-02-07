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

      # todo: if we ever have non-invite tracked links, then need to fix this
      send_zza_event_from_client("invitation.click")

      if tracked_link.shared_to == TrackedLink::SHARED_TO_EMAIL && tracked_link.type != TrackedLink::TYPE_INVITATION
        send_zza_event_from_client("invitation.#{tracked_link.type}.click")
      else
        send_zza_event_from_client("invitation.#{tracked_link.shared_to}.click")
      end

      redirect_to tracked_link.url
      return true
    else
      return false
    end
  end
end