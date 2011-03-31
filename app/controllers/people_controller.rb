class PeopleController < ApplicationController
  before_filter :require_album,             :only => [ :album_index ]
  before_filter :require_album_viewer_role, :only => [ :album_index ]

  # This is the people view for an album
  # @album is set by the require_album before_filter
  def album_index
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

  # To be run as a before_filter
  # sets @album
  def require_album
    @album = (params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] ) )
  end


end

