class PagesController < ApplicationController
  before_filter :require_user, :only => :contact


  def home
     @title = "Home"
     if current_user
       redirect_to user_albums_url( current_user.id )
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
