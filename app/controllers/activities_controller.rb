class ActivitiesController < ApplicationController
  def album_index
    @album = Album.find(params[:album_id])
  end

  def user_index
    @user = User.find(params[:user_id])
  end
end
