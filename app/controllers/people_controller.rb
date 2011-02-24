class PeopleController < ApplicationController

  def album_index
    @album = fetch_album


    #Find all of the album owner/creator photos
    @album_user_photos = @album.photos.find_all_by_user_id(@album.user_id)
    
    #Find all active and inactive contributors
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
          @inactive_names += ( i > 0 ? ', ':'')
          if !inactive_contributors[i].name.nil? && inactive_contributors[i].name.length > 0
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


private

  def fetch_album
    params[:user_id] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.find( params[:album_id] )
  end
  

end

