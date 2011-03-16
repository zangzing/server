class PeopleController < ApplicationController

  def album_index
    @album = fetch_album

    #An Array of users that are contributors including the album creator
    @contributors = []
    #List of email contributors that have not contributed yet

    @nonuser_contributors = 0
    @album.contributors.each do | id |
      user = User.find_by_id( id )
      if user
       @contributors << user
      else
       @nonuser_contributors +=1
      end
    end
    #an array  of users that have not contributed photos yet
    @inactive_contributors = []
    # An array of the users who like this album
    @likers = @album.likers | @album.users_who_like_albums_photos
  end

  def user_index
    @user = User.find(params[:user_id])
  end


private

  def fetch_album
    params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] )
  end
  

end

