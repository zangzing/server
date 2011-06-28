class ActivitiesController < ApplicationController
  before_filter :require_album,             :only => [ :album_index ]
  before_filter :require_album_viewer_role, :only => [ :album_index ]


  # The activities view for an album
  # @album is set by the require_album before_filter
  def album_index
    @activities = @album.activities
  end

  def user_index
    @user = User.find(params[:user_id])
    @activities = @user.activities
  end

private

  # To be run as a before_filter
  # sets @album
  def require_album
    @album = (params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] ) )
  end


end
