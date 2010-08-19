#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class AlbumsController < ApplicationController
  before_filter :require_user,     :except => [ :index, :show ]
  before_filter :authorized_user,  :only =>   [ :edit, :update, :destroy]

  def new
    render :choose_album_type;
  end

  def create
     if params[:album_type].nil?
      render :text => "Error No Album Type Supplied for Choose Album Type.", :status=>500 and return
    end
    @album  = params[:album_type].constantize.new()
    current_user.albums << @album
    @album.name = "Unamed Album"+ Time.new.strftime( ' %y-%m-%d %H:%M' )
    unless @album.save
      render :text => "Error in album create."+@album.errors.to_xml(), :status=>500 and return
    end
  end

  def upload
    #just show the view to load the filechooser.js
    @album = Album.find(params[:id])
  end

  def edit
    @album = Album.find(params[:id])
    params[:previous] = 'upload'
    params[:next] = 'update'
    render :layout => false;
  end

  def update
    @album = Album.find(params[:id])
    @album.update_attributes( params[:album] )
    render :action => :edit
  end

  def index
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

  def wizard
    if params[:id].nil?
      @steps = [:choose_album_type]
      @step = 0;
    else
      @id = params[:id]
      @album = Album.find(@id)
      @steps = @album.wizard_steps
      if params[:step].nil? || params[:step].to_i >= @steps.count
        @step = 1
      else
        @step = params[:step].to_i
      end
    end

    if request.post?
      #invoke the method. Each method will render their own response to the post
      current_step = @step
      if params[:next_step].nil?
        @step +=1
      else
        @step = @steps.index( params[:next_step].to_sym )
        if @step.nil? || @step >= @steps.count
          @step = 1;
        end
      end
      self.send( @steps[current_step] )
    else
      #request is a get, return the partial for the step requested
      render :action => @steps[@step], :layout => false
    end
  end

  def choose_album_type
    self.create
    render :text => @album.id, :status => 200, :layout => false and return
  end
  def add_photos
    render :text => 'Success Adding Photos', :status => 200, :layout => false and return
  end
  def name_album
    @album.update_attributes(params[:album])
    render :text => 'Success Naming Album', :status => 200, :layout => false and return
  end
  def edit_album
    render :text => 'Success Editing Album', :status => 200, :layout => false and return
  end
  def contributors
    render :text => 'Success Contributors', :status => 200, :layout => false and return
  end
  def share
    render :text => 'Success Share', :status => 200, :layout => false and return
  end

  private
  def authorized_user
    @album = Album.find(params[:id])
    redirect_to root_path unless current_user?(@album.user)
  end
end
