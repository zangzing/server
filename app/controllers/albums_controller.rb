class AlbumsController < ApplicationController
  before_filter :require_user,     :only => [ :new, :create ]
  before_filter :authorized_user, :only => :destroy

  def new
    @album = Album.new
    @title = "New Album"  
  end

  def create
      respond_to do |format|
           format.html do
             @album  = current_user.albums.build(params[:album])
             if @album.save
               flash[:success] = "Album created!"
               redirect_to @album
             else
               render 'new'
             end
           end
           format.xml do
             @user = User.find(params[:user_id])
             @album  = @user.albums.build(params[:album])
             if @album.save
               render :xml => @album.to_xml
             else
               render :xml => "ERROR CREATING ALBUM".to_xml
             end
           end
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
       @albums = @user.albums
  end
  
  private
      def authorized_user
        @album = Album.find(params[:id])
        redirect_to root_path unless current_user?(@album.user)
      end
  
 
end
