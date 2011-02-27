class ActivitiesController < ApplicationController
  def album_index
    @album = fetch_album
    @activities = @album.activities
  end

  def user_index
    @user = User.find(params[:user_id])
  end

private

  def fetch_album
    params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] )
  end

end
