class AlbumsController < ApplicationController
  before_filter :require_user
  before_filter :authorized_user, :only => :destroy

  def new
    @album = Album.new
    @title = "New Album"  
  end

  def create
      logger.debug "The params hash in AlbumController create is #{params.inspect}"
      respond_to do |format|
           format.html{
                       @album  = current_user.albums.build(params[:album])
                        if @album.save
                            flash[:success] = "Album created!"
                            redirect_to @album
                        else
                            render 'new'
                        end
                      }
           format.xml {
                        @user = User.find(params[:user_id])
                        @album  = @user.albums.build(params[:album])                        
                        if @album.save
                           render :xml => @album.to_xml
                        else
                            render :xml => "ERROR CREATING ALBUM".to_xml
                        end
                      }
         end
  end

  # This is the GRID view of the album
  def show
      @album = Album.find(params[:id])
      @user =  @album.user
      @photo = Photo.new   #This new empty photo is used for the photo upload form
      @photos = @album.photos.paginate(:page =>params[:page])
      @title = CGI.escapeHTML(@album.name)
  end

  # This is the SLIDESHOW View of the Album
  def slideshow
      @album = Album.find(params[:id])
      @user =  @album.user
      @photos = @album.photos.paginate({:page =>params[:page], :per_page => 1})
      unless  params[:photoid].nil?
        current_page = 1 if params[:page].nil?
        until @photos[0][:id] == params[:photoid].to_i
          current_page += 1
          @photos = @album.photos.paginate({:page =>current_page, :per_page => 1})
        end
        params[:photoid] = nil
      end
      @title = CGI.escapeHTML(@album.name)
  end

  def upload
    @album = Album.find(params[:id])
    @title = CGI.escapeHTML(@album.name)
  end

  def destroy
      # Album is found when the before filter calls authorized user
      @album.destroy
      redirect_back_or_default root_path
  end
  
  
  private
      def authorized_user
        @album = Album.find(params[:id])
        redirect_to root_path unless current_user?(@album.user)
      end
  
 
end
