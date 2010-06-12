class PagesController < ApplicationController

  def home
     @title = "Home"
     if current_user
       @albums = current_user.albums.paginate(:page => params[:page])
     end
   end
  
  def contact
    @title = "Contact"
  end
  
  def about
    @title ="About"
  end
  def help
    @title = "Help"
  end


end
