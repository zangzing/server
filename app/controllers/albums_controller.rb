#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  before_filter :require_user,     :except => [ :index, :show ]
  before_filter :authorized_user,  :only =>   [ :edit, :update, :destroy]

  def new
    render :layout => false
  end
  
  def timeline
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

  def upload_stat
    batch = Photo.find_all_by_user_id_and_album_id( current_user.id,  params[:id])

    if batch
#      photos_pending = batch.select{|p| ['assigned', 'loaded', 'processing'].include?(p.state)}
      photos_pending = batch.select{|p| ['assigned', 'loaded', 'processing'].include?(p.state)}
      photos_completed = batch.select{|p| ['ready'].include?(p.state) }
      unless photos_completed.empty? || photos_pending.empty?
        #est_time = (photos_completed.map{ |p| (p.image_updated_at.to_time - p.created_at.to_time)/60 }.sum / photos_completed.count) * photos_pending.count
        est_time = ((photos_completed.map(&:image_updated_at).compact.max - photos_completed.map(&:created_at).min)/photos_completed.size)/60 * photos_pending.size
      else
        est_time = 0
      end
      render :json => {
        'percent-complete' => (photos_completed.count.to_f/(photos_completed.count+photos_pending.count).to_f)*100,
        'time-remaining' => est_time,
        'photos-complete' => photos_completed.count,
        'photos-pending' => photos_pending.count
      }
    else
      #No active upload batches
      render :json => {'percent-complete' => 0, 'time-remaining' => nil, 'photos-complete' => 0, 'photos-pending' => nil}
    end
  end

  def preview_album_email
    @album = Album.find(params[:id])
    #base = @album.send(@album.friendly_id_config.method)
    if base = params[:album_name]
      begin
        text = @album.normalize_friendly_id(FriendlyId::SlugString.new(base))
        slug_text = FriendlyId::SlugString.new(text.to_s).validate_for!(@album.friendly_id_config).to_s
        current_slug = @album.slugs.new(:name => slug_text.to_s, :scope => @album.friendly_id_config.scope_for(@album), :sluggable => @album)
        render :text => "#{current_slug.to_friendly_id}.#{@album.user.friendly_id}@#{Server::Application.config.album_email_host}", :layout => false
      rescue FriendlyId::ReservedError
        flash[:error]="Sorry, \"#{base}\" is a reserved album name please try a different one"
        render :nothing => true, :layout => false, :status=>401
      end
    else
      render :nothing => true, :layout => false
    end
  end


  def add_photos
    render :layout => false
  end

  def name_album
    @album = Album.find(params[:id])
    render :layout => false
  end

  def privacy
    @album = current_user.albums.find( params[:id] )
    render :layout => false
  end

  def edit
    @album = Album.find(params[:id])
    @photos = @album.photos
    render :layout => false 
  end

  def update
    @album = Album.find(params[:id])
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

  def index
    UploadBatch.close_open_batches(current_user.id) if signed_in?
    @user = User.find(params[:user_id])
    if(current_user? @user)
      @albums = @user.albums  #show all albums
    else
      @albums = @user.albums #:TODO show only public albums unless the current user is the one asking for the index, then show all
    end
    #Setup badge vars
    @badge_name = @user.name
  end                                                           

  def show
    redirect_to album_photos_url( params[:id])
  end

  def destroy
    # Album is found when the before filter calls authorized user
    @album.destroy
    redirect_back_or_default root_path
  end

  def close_batch
     if params[:id]
        UploadBatch.close_open_batches( current_user.id, params[:id])
     end
  end
  private
  def authorized_user
    @album = Album.find(params[:id])
    redirect_to root_path unless current_user?(@album.user)
  end
end
