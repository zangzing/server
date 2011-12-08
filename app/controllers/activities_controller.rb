class ActivitiesController < ApplicationController

  # The activities view for an album
  # @album is set by the require_album before_filter
  def album_index
    return unless require_album(true) && require_album_viewer_role
    @activities = @album.activities
  end

  def user_index
    return unless require_nothing
    begin
      @user = User.find(params[:user_id])
      @activities = @user.activities
      @user_is_auto_follow = User.auto_like_ids.include?( @user.id )
      @is_homepage_view = true
    rescue ActiveRecord::RecordNotFound => e
      user_not_found_redirect_to_homepage_or_potd
      return
    end

  end

private

end
