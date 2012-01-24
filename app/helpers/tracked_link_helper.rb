module TrackedLinkHelper

  def check_link_tracking_token
    tracking_token = params[:ref]

    if tracking_token
      tracked_link = TrackedLink.find_by_tracking_token(tracking_token)
      TrackedLink.handle_visit(tracking_token)
      session[:tracking_token] = tracking_token
      redirect_to tracked_link.url
    end
  end

  def current_tracking_token
    session[:tracking_token]
  end

end