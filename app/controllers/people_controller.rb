class PeopleController < ApplicationController

  def album_index
    @album = fetch_album

    #An Array of Contributors starting with
    #The album's owner is not in the contributors list
    @contributors = []
    inactive_contributors = []
    @album.contributors.each do |c|
      if c.is_a_user?
       @contributors << c
      else
       inactive_contributors << c
      end
    end

    # A list of the contributors whoe are not users.
    @inactive_names = ''
    if inactive_contributors.length > 0
      @inactive_names = 'Other inactive contributors:  '
      inactive_contributors.each_index do | i |
          @inactive_names += ( i > 0 ? ', ':'')
          if !inactive_contributors[i].name.nil? && inactive_contributors[i].name.length > 0
                @inactive_names += inactive_contributors[i].name
          else
                @inactive_names += inactive_contributors[i].email
          end
      end
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

