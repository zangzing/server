class ActivitiesController < ApplicationController
  before_filter :require_album,             :only => [ :album_index ]
  before_filter :require_album_viewer_role, :only => [ :album_index ]


  # The activities view for an album
  # @album is set by the require_album before_filter
  def album_index
    @activities = @album.activities
  end

  def user_index
    begin
      @user = User.find(params[:user_id])
      @activities = @user.activities
      @user_is_auto_follow = User.auto_like_ids.include?( @user.id )
    rescue ActiveRecord::RecordNotFound => e
      user_not_found_redirect_to_homepage_or_potd
      return
    end

  end

private

  # To be run as a before_filter
  # sets @album
  def require_album
    begin
      @album = (params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] ) )
    rescue ActiveRecord::RecordNotFound => e
      album_not_found_redirect_to_owners_homepage(params[:user_id])
      return
    end
  end
end
