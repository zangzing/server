module TrackedLinkHelper

  def check_link_tracking_token
    tracking_token = params[:ref]

    if tracking_token
      tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
      if tracked_link  # check in case tracking token got mangled in copy/paste
        TrackedLink.handle_visit(tracking_token)
        session[:tracking_token] = tracking_token
        redirect_to tracked_link.url
      end
    end
  end

  def current_tracking_token
    session[:tracking_token]
  end

end