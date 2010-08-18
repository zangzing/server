class AlbumsController < ApplicationController
  before_filter :require_user,     :only => [ :new, :create, :upload ]
  before_filter :authorized_user, :only => :destroy

  def new
    @album = Album.new
    @title = "New Album"  
  end

  def create
    @album  = current_user.albums.build(params[:album])
    if @album.save
      render :text => @album.id
    else
      render :text => "Error in album create."+@album.errors.to_xml()
    end
  end

  
  def show
      redirect_to album_photos_url( params[:id])
  end


  def upload
    @album = Album.find(params[:id])
    #just show the view
  end



  def destroy
      # Album is found when the before filter calls authorized user
      @album.destroy
      redirect_back_or_default root_path
  end

  def index
       @user = User.find(params[:user_id])

       if(current_user? @user)
          @albums = @user.albums  #show all albums
       else
         @albums = @user.albums #:TODO show only public albums unless the current user is the one asking for the index, then show all
       end

       #Setup badge vars
       @badge_name = @user.name
      
  end
  
  private
      def authorized_user
        @album = Album.find(params[:id])
        redirect_to root_path unless current_user?(@album.user)
      end
  
 
end
