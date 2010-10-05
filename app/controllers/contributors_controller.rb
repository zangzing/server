class ContributorsController < ApplicationController
  before_filter :require_user
  layout false

  def new
    @album = current_user.albums.find(params[:album_id])    
    @contributor = Album.new(); #TODO:Contributor model
  end



  def create
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to add contributors"
      respond_to do |format|
        format.html  { render :action => 'new' and return }
        format.json { render :json =>{:status => 404, :flash => flash } and return }
      end
    else
      begin
        Contributor.factory( @album, params[:email_share][:to])
        @album.save!
      rescue ActiveRecord::RecordInvalid => invalid
        respond_to do |format|
          format.html  { redirect_to new_album_contributors_url(@album)   }
          format.json  { errors_to_headers( invalid.record )
                         render :json => "", :status => 400 and return}
        end
      end    

      flash[:notice] = "The contributors were added to your album"
      respond_to do |format|
          format.html  { redirect_to album_url(@album)   }
          format.json { render :json => "", :status => 200 and return }
       end
    end
  end

  def index
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to display contributors"
      render :action =>'new'
    end
    @contributors = @album.contributors
 end

  def destroy
    @contributor = Contributor.find( params[:id] )
    if @contributor.nil?
      flash[:error] ="Contributor with id=#{params[:id]} not found."
      render :status => 404 and return
    end
    if current_user == @contributor.album.user || current_user.admin?
      @contributor.destroy
      flash[:notice] = "Contributor deleted"
      render and return
    end
    flash[:error] ="Only album owners and admins can delete contributors."
    render :status => 500 and return        
  end
end
