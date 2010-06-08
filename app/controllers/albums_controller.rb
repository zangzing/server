class AlbumsController < ApplicationController
  before_filter :authenticate
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


  def show
      @album = Album.find(params[:id])
      @user =  @album.user
      @photo = Photo.new
      @photos = @album.photos.paginate(:page =>params[:page])
      @title = CGI.escapeHTML(@album.name)
      respond_to do |format|
           format.html{
                render 'show'
           }
           format.json{
                headers["Content-Type"] = "text/plain; charset=utf-8"
                render :text => @album.to_json(:only => :name,  :include => { :photos =>{:only =>[], :methods => [:thumb_url]}})
           }
      end
  end

  def upload
    @album = Album.find(params[:id])
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
