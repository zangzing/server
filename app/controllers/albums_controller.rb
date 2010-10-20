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
    batch = UploadBatch.find_by_user_id_and_album_id_and_state(current_user.id, params[:id], 'open')

    if batch
      photos_pending = batch.photos.find(:all, :conditions => {:state => ['assigned', 'loaded', 'processing']})
      photos_completed = batch.photos.find(:all, :conditions => {:state => 'ready'})
      unless photos_completed.empty?
        #est_time = (photos_completed.map{ |p| (p.image_updated_at.to_time - p.created_at.to_time)/60 }.sum / photos_completed.count) * photos_pending.count
        est_time = ((photos_completed.map(&:image_updated_at).max - photos_completed.map(&:created_at).min)/photos_completed.size)/60 * photos_pending.size
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
      render :json => {'percent-complete' => 100, 'time-remaining' => 0, 'photos-complete' => nil, 'photos-pending' => nil}
    end
  end


  def add_photos
    @album = Album.find(params[:id])
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
    @album.update_attributes( params[:album] )
    render :text => 'Success Updating Album', :status => 200, :layout => false
  end

  def index
    UploadBatch.close_open_batches(current_user) if signed_in?
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

  private
  def authorized_user
    @album = Album.find(params[:id])
    redirect_to root_path unless current_user?(@album.user)
  end
end
