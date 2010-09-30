class ContributorsController < ApplicationController
  before_filter :require_user
  layout false

    
  def new
    @album = current_user.albums.find(params[:album_id])    
    @google_id = current_user.identity_for_google
    @yahoo_id  = current_user.identity_for_yahoo
    @local_id  = current_user.identity_for_local
    @contributor = Album.new(); #TODO:Contributor model
  end

  def create
    @album = current_user.albums.find(params[:album_id])
    if @album.nil?
      flash[:error] = "Album not found. Unable to add contributors"
      respond_to do |wants|
        wants.html  { render :action => 'new' and return }
        format.json { render :json =>{:status => 404, :flash => flash } and return }
      end
    else
      if rand(10) > 5  #TODO:Implement real functionality
        flash[:notice] = "The new contributor list was added to your album"
        respond_to do |format|
          format.html  { redirect_to album_url(@album)   }
          format.json { render :json =>{:status => 200, :flash => flash } and return }
        end
      else
        flash[:error] = "Unable to create contributor list"
        respond_to do |format|
          format.html  { redirect_to new_album_contributors_url(@album)   }
          format.json { render :json =>{:status => 400, :flash => flash } and return}
        end
      end
    end
  end

  def index
  end

  def destroy
  end
end
