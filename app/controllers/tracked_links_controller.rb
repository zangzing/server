class TrackedLinksController < ApplicationController

  def show
    unless handle_tracked_link(params[:tracking_token])
      raise ActiveRecord::RecordNotFound.new().message = "Could not find TrackedLink with tracking_token=#{params[:tracking_token]}"
    end
  end
end
