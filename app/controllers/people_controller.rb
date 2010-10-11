class PeopleController < ApplicationController
  def album_index
    @album = Album.find(params[:album_id])
    @active_contributors = []
    @album.contributors.each { |c| @active_contributors << c if c.is_a_user? }
  end

  def user_index
    @user = User.find(params[:user_id])
  end

end
