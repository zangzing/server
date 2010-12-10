class PhotosController < ApplicationController
  before_filter :oauth_required, :only => [:agentindex, :upload, :agent_create]
  before_filter :login_required, :only => [:create]
  before_filter :require_user, :only => [:show, :new, :edit, :destroy] # , :index] #TODO Sort out album security so facebook can freely dig into album page
  before_filter :determine_album_user #For friendly_id's scope

  def show
    @photo = Photo.find(params[:id])
    @album = @photo.album
    @title = CGI.escapeHTML(@album.name)
  end

  def create
    @album = fetch_album
    @photo = @album.photos.build(params[:photo])
    @photo.user = current_user

    respond_to do |format|
      format.html do
        if @photo.save
          flash[:success] = "Photo Created!"
          render :action => :show
        else
          render :action => :new
        end
      end
      format.json do
        if @photo.save
          render :json => @photo.to_json(:only =>[:id, :agent_id, :state])
        else
          render :json => @photo.errors, :status=>500
        end
      end
    end
  end


  def agent_create
    @album = fetch_album
    @photos = []

    if params[:source_guid].nil?
      render :json => "source_guid parameter required. Unable to create photos", :status=>400
    end

    (0...params[:source_guid].length).each do |index|
      source_guid = params[:source_guid][index.to_s]
      size = params[:size][index.to_s]
      caption = params[:caption][index.to_s]

      @photo = @album.photos.build(:agent_id => params[:agent_id], :source_guid => source_guid, :caption => caption, :image_file_size => size)
      @photo.user = current_user
      @photos << @photo


      #todo: need to handle agent port and url templates in central place
      @photo.source_thumb_url = "http://localhost:30777/albums/#{@album.id}/photos/:photo_id.thumb"
      @photo.source_screen_url = "http://localhost:30777/albums/#{@album.id}/photos/:photo_id.screen"

      if @photo.save

      else
        render :json => photo.errors, :status=>500
        return
      end
    end

#    render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :source_thumb_url, :source_screen_url, :source_guid], :methods => [:thumb_url, :medium_url])
    #GWS debugging aid, put above line back when done
    debugstr = @photos.to_json(:only =>[:id, :agent_id, :state, :source_thumb_url, :source_screen_url, :source_guid], :methods => [:thumb_url, :medium_url])
    render :json => debugstr
  end


  def agentindex
    begin
      @photos = Photo.all(:conditions => ["agent_id = ? AND state = ?", params[:agent_id], 'assigned'])
      render :json => @photos.to_json(:only =>[:id, :agent_id, :state, :album_id])

    rescue ActiveRecord::StatementInvalid => ex
      #this seems to mean connection issue with database
      render :json => ex.to_s, :status=>500

    rescue Exception => ex
      render :json => ex.to_s, :status=>500

    end
  end


  def upload
    begin
      @photo = Photo.find(params[:id])
      @album = @photo.album
      if @photo.update_attributes(params[:photo])
        render :json => @photo.to_json(:only =>[:id, :agent_id, :state])
      else
        render :json => @photo.errors, :status=>400
      end
    rescue ActiveRecord::RecordNotFound => ex
      #photo or album have been deleted
      render :json => ex.to_s, :status=>400

    rescue ActiveRecord::StatementInvalid => ex
      #this seems to mean connection issue with database
      render :json => ex.to_s, :status=>500

    rescue Exception => ex
      #todo: make sure none of these should be 4xx errors
      render :json => ex.to_s, :status=>500
    end
  end

  def destroy
    logger.debug "The params hash in PhotosController destroy is #{params.inspect}"
    @photo = Photo.find(params[:id])
    @album = @photo.album
    respond_to do |format|
      format.html do
        if !@photo.destroy
          flash[:error] = "Unable to delete photo!"
        end
        redirect_to @album
      end
      format.json do
        if !@photo.destroy
          render :json => @photo.errors, :status=>500
        end
        render :json => "Photo deleted".to_json
      end
    end
  end

  #
  # Shows all photos for a given album
  #
  # Photos can be shown in a slideshow or a grid based on the query arguments
  #
  # size         thumb|screeenres  Show all thumbnails or 1 screenres.
  #              Default: show all thumbs
  # photoid      Id of photo that should be displayed when in screenres
  #              Default: Show first pic in album
  # page         Page desired when in screenres                         
  #              Default: First
  # upload_batch Display only album photos in given upload_batch
  #              upload_batch must belong to album
  # contributor  Display only photos contributed by certain contributor.
  #              contributor must be in albums contributor list
  def index
    @album = fetch_album
    @title = CGI.escapeHTML(@album.name)

    UploadBatch.close_open_batches( current_user, @album) if signed_in?

    if params[:upload_batch] && @upload_batch = UploadBatch.find(params[:upload_batch])
      @photos = @upload_batch.photos
      @return_to_link = "#{album_activities_path( @album )}##{@upload_batch.id}"
    elsif params[:contributor] && @contributor = Contributor.find(params[:contributor])
      @photos = @contributor.photos
      @return_to_link = "#{album_people_path( @album )}##{@contributor.id}"
    else
      @photos = @album.photos
      @return_to_link = album_photos_url( @album.id )
    end

    respond_to do |format|
      format.json do
         render :json => @photos.to_json(:methods => [:thumb_url, :medium_url]) and return
     end
#
      format.html do
        if !params[:view].nil? && params[:view] == 'slideshow'
          if params[:photoid].nil?
            @photos = @photos.paginate({:page =>params[:page], :per_page => 1})
          else
            if params[:page].nil?
              current_page = 1
            end
            until @photos[0][:id] == params[:photoid]
              current_page += 1
              @photos = @photos.paginate({:page =>current_page, :per_page => 1})
            end
            params[:photoid] = nil
          end
          render 'slideshow' and return
        elsif !params[:view].nil? && params[:view] == 'movie'
          render 'movie', :layout => false and return
        else
         render 'grid' and return
        end
      end
    end
  end

  def slideshowbox_source
    @album = fetch_album
    @photos = @album.photos
    respond_to do |format|
      format.xml
    end
  end


#
  # Shows all photos for a given album
  #
  # Photos can be shown in a slideshow or a grid based on the query arguments
  #
  # size         thumb|screeenres  Show all thumbnails or 1 screenres.
  #              Default: show all thumbs
  # photoid      Id of photo that should be displayed when in screenres
  #              Default: Show first pic in album
  # page         Page desired when in screenres
  #              Default: First
  #
  def edit
    @album = fetch_album
    @title = CGI.escapeHTML(@album.name)

    respond_to do |format|
      format.html do
        if !params[:view].nil? && params[:view] == 'slideshow'
          @photos = @album.photos.paginate({:page =>params[:page], :per_page => 1})
          unless  params[:photoid].nil?
            current_page = 1 if params[:page].nil?
            until @photos[0][:id] == params[:photoid]
              current_page += 1
              @photos = @album.photos.paginate({:page =>current_page, :per_page => 1})
            end
            params[:photoid] = nil
          end
          render 'slideshow'
        else
          @photo = Photo.new
          @photos = @album.photos
          render 'grid'
        end
      end

      format.json do
        render :json => @album.photos.to_json(:methods => [:thumb_url, :medium_url])
      end
    end
  end

private

  def fetch_album
    params[:friendly] ? Album.find(params[:album_id], :scope => params[:user_id]) : Album.first(:conditions => {:id => params[:album_id]})
  end

  def determine_album_user
    @album_user_id = params[:user_id] #|| current_user.to_param
  end

end
