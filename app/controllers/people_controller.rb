class PeopleController < ApplicationController
  def album_index
    @album = Album.find(params[:album_id])
    @contributors = []
    inactive_contributors = []
    @album.contributors.each do |c|
      if c.is_a_user?
       @contributors << c
      else
       inactive_contributors << c
      end
    end

    @inactive_names = ''
    if inactive_contributors.length > 0
      @inactive_names = 'Other contributors: '      
      inactive_contributors.each_index do | i |
          @inactive_names += ( i> 0 ? ', ':'')
          if inactive_contributors[i].name.length > 0
                @inactive_names += inactive_contributors[i].name
          else
                @inactive_names += inactive_contributors[i].email
          end
      end
    end
  end

  def user_index
    @user = User.find(params[:user_id])
  end

end

