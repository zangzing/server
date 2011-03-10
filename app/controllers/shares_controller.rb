#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class SharesController < ApplicationController

  layout false

  respond_to :html, :only => [:new, :newpost, :newemail]
  respond_to :json, :only => [:create]

  def new
     @album = Album.find(params[:album_id])
  end

  def newpost
      @share = Share.new()
      @twitter  = ( current_user.identity_for_twitter.credentials_valid? ? "1" :"0" )
      @facebook = ( current_user.identity_for_facebook.credentials_valid? ? "1" :"0" )
  end

  def newemail
    @share = Share.new()
  end

  def create
    # Based on the route used to get here (and thus the params) we know what kind of subject does
    # the user wants to quack! about.
    if  params[:user_id]
        @subject = User.find(params[:user_id])
        @subject_url = user_url(@subject)
    elsif params[:album_id]
        @subject = Album.find(params[:album_id])
        @subject_url = album_photos_url(@subject)
    elsif params[:photo_id]
        @subject = Photo.find(params[:photo_id])
        @subject_url = album_photos_url(@subject.album)  #TODO: Get url for photo
    else
        render :json => "subject_type not specified via params", :status => 400 and return
    end

    # make sure recipients its an array
    # emailshare submits a comma separated list of emails
    # postshare submits an array of social services
    rcp = (  params[:recipients].is_a?(Array) ? params[:recipients] : params[:recipients].split(',') )
    @share = Share.new( :user =>        current_user,
                        :subject =>     @subject,
                        :subject_url => @subject_url,
                        :service =>     params[:service],
                        :recipients =>  rcp,
                        :message    =>  params[:message])

    unless @share.save
      errors_to_headers( @share )
      render :json => "", :status => 400 and return
    end

    if @share.album?
      flash[:notice] = "Your album will be shared as soon as its ready."
    end
    
    render :json =>"", :status => 200
  end

end