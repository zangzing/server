class AlbumsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def new
    @album = Album.new
    @title = "New Album"  
  end

  def create
      @album  = current_user.albums.build(params[:album])
      if @album.save
        flash[:success] = "Album created!"
        redirect_to @album
      else
        render 'new'
      end
  end


  def show
      @album = Album.find(params[:id])
      @user =  @album.user
      @photo = Photo.new
      @photos = @album.photos.paginate(:page =>params[:page])
      @title = CGI.escapeHTML(@album.name)
  end

  def destroy
      # Album is found when the before filter calls authorized user
      @album.destroy
      redirect_back_or root_path
  end
  
  
  private

      def authorized_user
        @album = Album.find(params[:id])
        redirect_to root_path unless current_user?(@album.user)
      end
  
 
end
