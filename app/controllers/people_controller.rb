class PeopleController < ApplicationController

  def album_index
    @album = fetch_album

    #An Array of users that are contributors including the album creator
    @contributors = []
    #List of email contributors that have not contributed yet
    inactive_contributors = []
    @album.contributors.each do |c|
      c = User.find_by_id( c )
      if c
       @contributors << c
      else
       inactive_contributors << c
      end
    end

    # A list of the contributors whoe are not users.
    @inactive_names = ''
    if inactive_contributors.length > 0
      @inactive_names = 'Other inactive contributors:  '+ inactive_contributor.join(',')
    end

    # An array of the users who like this album
    @likers = @album.likers
  end

  def user_index
    @user = User.find(params[:user_id])
  end


private

  def fetch_album
    params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] )
  end
  

end

