#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class SharesController < ApplicationController

  layout false

  def index   
  end

  def new
     @album = Album.find(params[:album_id])
  end

  def newpost
      @album = Album.find(params[:album_id])
      @share = PostShare.new
      @share.twitter  = ( current_user.identity_for_twitter.credentials_valid? ? "1" :"0" )
      @share.facebook = ( current_user.identity_for_facebook.credentials_valid? ? "1" :"0" )    
  end

  def newemail
    @album = Album.find(params[:album_id])
    @share = EmailShare.new    
    @google_id = current_user.identity_for_google
    @yahoo_id  = current_user.identity_for_yahoo
    @local_id  = current_user.identity_for_local
  end
  
  def create
    @album = Album.find(params[:album_id])
    @share = Share.factory( current_user, @album, params)
    @share.link_to_share = album_photos_url(@album)
    
    unless @share.save
      respond_to do |format |
          format.html { render 'newemail' and return  if params[:mail_share]
                        render 'newpost' and return  if params[:post_share]  }
          format.json {  render :json=> {:status => 400, :errors => @share.errors.full_messages} and return }
      end
    end
    @share.deliver_later
    flash[:notice] = "Share Created"
    respond_to do |format |
          format.html   
          format.json {  render :json=> {:status => 200, :flash => flash } and return }
    end    
  end

  def edit
    @share = Share.find(params[:id])
    @album = @share.album

    case @share
      when EmailShare then
        @google_id = current_user.identity_for_google
        @yahoo_id  = current_user.identity_for_yahoo
        @contacts = []
        @contacts.concat @google_id.contacts unless @google_id.nil?
        @contacts.concat @yahoo_id.contacts unless @yahoo_id.nil?
        render 'newemail'
      when PostShare then
        render 'newpost'
    end
  end

end