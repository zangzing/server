#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  before_filter :require_user,              :except => [ :index , :show, :back_to_index ]
  before_filter :require_album,             :except => [ :index, :create, :new, :show  ]
  before_filter :require_album_admin_role,  :only =>   [ :destroy, :edit, :update ]

  # displays the "Select album type screen" used in the wizard
  def new
    render :layout => false
  end

 def create
    if params[:album_type].nil?
      render :text => "Error No Album Type Supplied. Please Choose Album Type.", :status=>500 and return
    end
    @album  = params[:album_type].constantize.new()
    current_user.albums << @album
    @album.name = "New Album"
    unless @album.save
      render :text => "Error in album create."+@album.errors.to_xml(), :status=>500 and return
    end
    render :text => @album.id, :status => 200, :layout => false and return
  end

  # Used in the name tab of the wizard. It displays a preview
  # of what the album email will be as the album name changes
  # @album is set in the require_album before filter
  def preview_album_email
    if base = params[:album_name]
      begin
        text = @album.normalize_friendly_id(FriendlyId::SlugString.new(base))
        slug_text = FriendlyId::SlugString.new(text.to_s).validate_for!(@album.friendly_id_config).to_s
        current_slug = @album.slugs.new(:name => slug_text.to_s, :scope => @album.friendly_id_config.scope_for(@album), :sluggable => @album)
        render :text => "#{current_slug.to_friendly_id}@#{@album.user.friendly_id}.#{Server::Application.config.album_email_host}", :layout => false
      rescue FriendlyId::ReservedError
        flash[:error]="Sorry, \"#{base}\" is a reserved album name please try a different one"
        render :nothing => true, :layout => false, :status=>401
      end
    else
      render :nothing => true, :layout => false
    end
  end

  # displays the name album page for the wizard
  # @album is set by the require album before filter
  def name_album
       render :layout => false
  end

  # displays the album privacy page for the wizard
  # @album is set by the require album before filter
  def privacy
    render :layout => false
  end

  # displays the edit page for the wizard
  # @album is set by the require album before filter
  def edit
    @photos = @album.photos
    render :layout => false 
  end

  # updates @album attributes
  # @album is set by the require_album before_filter
  def update
    # The AlbumCoverPicker sends an empty string when no cover has been selected. Delete param if that is the case
    # TODO: Fix AlbumCoverPicker to omit cover_photo_id parameter if not set by user
    params[:album].delete(:cover_photo_id) if params[:album][:cover_photo_id] && params[:album][:cover_photo_id].length <= 0  
    if @album && @album.update_attributes( params[:album] )
      flash[:notice] = "Album Updated!"
      render :text => 'Success Updating Album', :status => 200, :layout => false
    else
      #flash[:notice]="Your album update did not succeed please check X-Errors header for details"
      errors_to_headers( @album )
      render :text => 'Album update did not succeed', :status => 500, :layout => false
    end
  end

  # This is effectively the users homepage
  def index
    @user = User.find(params[:user_id])

    store_last_home_page @user.id

    liked_users_public_albums = @user.liked_users_public_albums
    # if we are showing the owners albums, show them all as well as any linked albums and any public albums for users that the user likes
    # for a different user than the current logged in user, just show all public albums including any that the users likes and
    # any public ones that get pulled in from users that we like
    # When the user visits her hompage show
    #    -All of her albums
    #    -All he liked albums
    #    -All of her liked users public albums
    # When the user visits joe's homepage show
    #    -All of joe's user public albums
    #    -All of joe's liked public albums
    #    -All of joe's lked users' public albums
    if( current_user? @user || current_user.support_hero? )
      @albums = @user.albums | @user.liked_albums | liked_users_public_albums #show all of current_user's albums
    else
      @albums = @user.albums.where("privacy = 'public' AND completed_batch_count > 0") |
                @user.liked_public_albums | liked_users_public_albums
    end
    #@albums = @albums.sort { |a1, a2| a2.updated_at <=> a1.updated_at }

    #Setup badge vars
    @badge_name = @user.name
  end

  # displays all of an albums photos
  def show
    redirect_to album_photos_url(params[:id])
  end

  #deletes an album
  #@album is set by require_album before_filter
  def destroy
    # Album is found when the before filter calls authorized user
    if !@album.destroy
      render :json => @album.errors, :status=>500
    end
    render :json => "Album deleted".to_json

  end

  #closes the current batch
  # we also have a watchdog sweeper that will
  # close batches with no new add activity after a 5 minute window
  def close_batch
    album_id = params[:id]
    if album_id
      UploadBatch.close_open_batch( current_user.id, album_id)
    end
    render :nothing => true
  end

  #displays the "You have reached a password protected album, request access" dialog
  def pwd_dialog
    render :layout => false
  end

  # Receives and processes a user's request for access into a password protected album
  def request_access
    #TODO: Receive and process current_users request for access into the current album
  end


  private
    #
    # To be run as a before_filter
    # Requires params[:id] to be present and be a valid album_id.
    # sets @album to be Album.find( params[:id ])
    # Throws ActiveRecord:RecordNotFound exception if params[:id] is not present or the album is not found
    def require_album
      begin
        @album = Album.find( params[:id ])  #will trhow exception if params[:id] is not defined or album not found
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = "This operation requires an album, we could not find one because: "+e.message
        response.headers['X-Error'] = flash[:error]
        if request.xhr?
          render :status => 404
        else
          render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
        end
        return false
      end
    end

end
